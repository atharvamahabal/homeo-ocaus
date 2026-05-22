import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/doctor.dart';
import '../domain/appointment.dart';
import '../data/patient_repository.dart';
import '../../auth/data/auth_repository.dart';

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  final Doctor doctor;

  const AppointmentBookingScreen({super.key, required this.doctor});

  @override
  ConsumerState<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends ConsumerState<AppointmentBookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  bool _isLoading = false;
  List<String> _bookedSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  Future<void> _fetchBookedSlots() async {
    final slots = await ref.read(patientRepositoryProvider).getBookedSlots(widget.doctor.id, _selectedDate);
    if (mounted) {
      setState(() {
        _bookedSlots = slots.map((a) => DateFormat('hh:mm a').format(a.dateTime)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book with ${widget.doctor.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Doctor Info Header
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    widget.doctor.name[0],
                    style: TextStyle(fontSize: 32, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.doctor.specialization,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Date Selection
            Text(
              'Select Date',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month),
                title: Text(DateFormat('EEEE, MMMM d, y').format(_selectedDate)),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      _selectedTime = null;
                    });
                    _fetchBookedSlots();
                  }
                },
              ),
            ),
            const SizedBox(height: 32),

            // Time Selection
            Text(
              'Select Time Slot',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.doctor.timeSlots.where((time) => !_bookedSlots.contains(time)).map((time) {
                final isSelected = _selectedTime == time;
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedTime = selected ? time : null);
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),

            // Confirm Button
            ElevatedButton(
              onPressed: (_selectedTime == null || _isLoading)
                  ? null
                  : _bookAppointment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm Booking', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookAppointment() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check if profile exists before booking
      final profile = await ref.read(patientRepositoryProvider).getProfile(user.uid);
      if (profile == null) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Profile Incomplete'),
              content: const Text('Please complete your profile before booking an appointment.'),
              actions: [
                TextButton(
                  onPressed: () => context.go('/onboarding'),
                  child: const Text('Complete Profile'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Parse time
      final timeParts = _selectedTime!.split(' ');
      final hourMin = timeParts[0].split(':');
      int hour = int.parse(hourMin[0]);
      int minute = int.parse(hourMin[1]);
      if (timeParts[1] == 'PM' && hour < 12) hour += 12;
      if (timeParts[1] == 'AM' && hour == 12) hour = 0;

      final appointmentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      );

      final appointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: user.uid,
        doctorId: widget.doctor.id,
        doctorName: widget.doctor.name,
        dateTime: appointmentDateTime,
        status: 'pending',
        type: 'clinic',
        amount: 500, // Default consultation fee
      );

      await ref.read(patientRepositoryProvider).bookAppointment(appointment);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String errorMessage = e.toString();
        
        // Show the raw error for debugging if it's a permission issue
        if (errorMessage.contains('permission-denied') || errorMessage.contains('Permission Denied')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Firestore Error'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('The operation was denied by Firestore.'),
                  const SizedBox(height: 12),
                  const Text('Potential Reasons:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('• Your Firestore Security Rules are blocking the write.'),
                  const Text('• The collection "appointments" does not exist or is misconfigured.'),
                  const SizedBox(height: 12),
                  const Text('Raw Error:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(errorMessage, style: const TextStyle(fontSize: 12, color: Colors.red)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
