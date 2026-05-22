import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/health_record.dart';
import '../../../core/utils/pdf_generator.dart';

class ConsultationDetailScreen extends StatelessWidget {
  final HealthRecord record;

  const ConsultationDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Consultation Details'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.green),
            onPressed: () => PdfGenerator.generateConsultationPdf(record),
            tooltip: 'Download as PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Card(
              elevation: 4,
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.green, width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeaderRow(context, Icons.calendar_today, 'Date & Time', 
                        DateFormat('EEEE, MMM d, y • HH:mm:ss').format(record.date)),
                    Divider(height: 24, color: Colors.white.withOpacity(0.1)),
                    _buildHeaderRow(context, Icons.person_outline, 'Patient Name', record.patientName),
                    Divider(height: 24, color: Colors.white.withOpacity(0.1)),
                    _buildHeaderRow(context, Icons.person, 'Doctor', record.doctorName),
                    Divider(height: 24, color: Colors.white.withOpacity(0.1)),
                    _buildHeaderRow(context, Icons.medical_services, 'Diagnosis', record.diagnosis),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // SOAP Sections
            _buildSectionTitle(context, 'Subjective (Symptoms)', Icons.psychology),
            _buildContentCard(context, record.symptoms.isEmpty ? 'No symptoms recorded' : record.symptoms.join(', ')),
            
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Objective & Plan', Icons.assignment_outlined),
            _buildContentCard(context, record.notes ?? 'No additional notes'),

            if (record.followUpDate != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Next Follow-up', Icons.event_repeat),
              _buildContentCard(context, DateFormat('EEEE, MMM d, y • HH:mm a').format(record.followUpDate!)),
            ],

            const SizedBox(height: 32),
            // Prescription Section
            _buildSectionTitle(context, 'Digital Prescription', Icons.medication),
            const SizedBox(height: 12),
            if (record.remedies.isEmpty)
              const Text('No remedies prescribed', style: TextStyle(color: Colors.white70))
            else
              ...record.remedies.map((remedy) => _buildRemedyCard(context, remedy)),

            const SizedBox(height: 40),
            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => PdfGenerator.generateConsultationPdf(record),
                icon: const Icon(Icons.download),
                label: const Text('Download PDF Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              Text(
                value, 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.5),
      ),
    );
  }

  Widget _buildRemedyCard(BuildContext context, PrescribedRemedy remedy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    remedy.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    remedy.potency,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRemedyDetail(Icons.access_time, remedy.frequency),
                const SizedBox(width: 16),
                _buildRemedyDetail(Icons.scale, remedy.dosage),
              ],
            ),
            if (remedy.instructions != null && remedy.instructions!.isNotEmpty) ...[
              const Divider(height: 24, color: Colors.white10),
              Text(
                'Instructions: ${remedy.instructions}',
                style: const TextStyle(fontSize: 13, color: Colors.white70, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRemedyDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.green),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.white70)),
      ],
    );
  }
}
