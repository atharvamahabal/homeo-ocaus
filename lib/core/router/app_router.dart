import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/onboarding/presentation/profile_setup_screen.dart';
import '../../features/patient/presentation/patient_home_screen.dart';
import '../../features/patient/presentation/doctor_list_screen.dart';
import '../../features/patient/presentation/appointment_booking_screen.dart';
import '../../features/patient/presentation/health_records_screen.dart';
import '../../features/patient/presentation/doctor_appointments_screen.dart';
import '../../features/doctor/presentation/doctor_dashboard_screen.dart';
import '../../features/doctor/presentation/patient_management_screen.dart';
import '../../features/doctor/presentation/patient_detail_screen.dart';
import '../../features/doctor/presentation/admin_panel_screen.dart';
import '../../features/patient/presentation/remedy_chat_screen.dart';
import '../../features/patient/presentation/consultation_detail_screen.dart';
import '../../features/patient/domain/health_record.dart';
import '../../features/patient/domain/doctor.dart';
import '../../features/auth/domain/patient_profile.dart';

import '../../features/auth/data/auth_repository.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      
      if (isLoggedIn && isLoggingIn) {
        final user = authState.value;
        final adminEmails = ['atharva.smahabal@gmail.com', 'homeo.ocus@gmail.com'];
        if (adminEmails.contains(user?.email)) {
          return '/doctor/dashboard';
        }
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const PatientHomeScreen(),
      ),
      GoRoute(
        path: '/doctor/dashboard',
        name: 'doctor-dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/doctor/patients',
        name: 'doctor-patients',
        builder: (context, state) => const PatientManagementScreen(),
      ),
      GoRoute(
        path: '/doctor/patient-details',
        name: 'doctor-patient-details',
        builder: (context, state) {
          final patient = state.extra as PatientProfile;
          return PatientDetailScreen(patient: patient);
        },
      ),
      GoRoute(
        path: '/doctor/admin',
        name: 'doctor-admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),
      GoRoute(
        path: '/doctors',
        name: 'doctors',
        builder: (context, state) => const DoctorListScreen(),
      ),
      GoRoute(
        path: '/booking',
        name: 'booking',
        builder: (context, state) {
          final doctor = state.extra as Doctor;
          return AppointmentBookingScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/records',
        name: 'records',
        builder: (context, state) => const HealthRecordsScreen(),
      ),
      GoRoute(
        path: '/doctor-appointments',
        name: 'doctor-appointments',
        builder: (context, state) {
          final doctor = state.extra as Doctor;
          return DoctorAppointmentsScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/consultation-detail',
        name: 'consultation-detail',
        builder: (context, state) {
          final record = state.extra as HealthRecord;
          return ConsultationDetailScreen(record: record);
        },
      ),
      GoRoute(
        path: '/ai-chat',
        name: 'ai-chat',
        builder: (context, state) => const RemedyChatScreen(),
      ),
    ],
  );
});
