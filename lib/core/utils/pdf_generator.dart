import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/patient/domain/health_record.dart';

class PdfGenerator {
  static Future<void> generateConsultationPdf(HealthRecord record) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Homeo ओकस',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text('Homeopathic Clinic Management System'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Consultation Report',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(DateFormat('EEEE, MMM d, y • HH:mm:ss').format(record.date)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.blue900),
              pw.SizedBox(height: 20),

              // Patient & Doctor Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Patient Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(record.patientName),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Doctor Information', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(record.doctorName),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Diagnosis', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(record.diagnosis),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Symptoms Section
              _buildSectionTitle('Symptoms (Subjective)'),
              pw.Text(record.symptoms.isEmpty ? 'None recorded' : record.symptoms.join(', ')),
              pw.SizedBox(height: 20),

              // Notes Section
              _buildSectionTitle('Clinical Notes (Objective & Plan)'),
              pw.Text(record.notes ?? 'None recorded'),
              pw.SizedBox(height: 20),

              // Follow-up Section
              if (record.followUpDate != null) ...[
                _buildSectionTitle('Next Follow-up'),
                pw.Text(DateFormat('EEEE, MMM d, y • HH:mm a').format(record.followUpDate!)),
                pw.SizedBox(height: 20),
              ],

              pw.SizedBox(height: 10),

              // Prescription Section
              _buildSectionTitle('Digital Prescription'),
              if (record.remedies.isEmpty)
                pw.Text('No remedies prescribed')
              else
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  headerHeight: 25,
                  cellHeight: 30,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headers: ['Remedy', 'Potency', 'Dosage', 'Frequency', 'Duration'],
                  data: record.remedies.map((r) => [
                    r.name,
                    r.potency,
                    r.dosage,
                    r.frequency,
                    r.duration,
                  ]).toList(),
                ),

              pw.Spacer(),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Generated by Homeo ओकस App',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Consultation_${DateFormat('yyyyMMdd_HHmmss').format(record.date)}.pdf',
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.Container(height: 1, width: 100, color: PdfColors.blue700),
          pw.SizedBox(height: 8),
        ],
      ),
    );
  }
}
