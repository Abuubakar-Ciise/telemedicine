import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tele/Models/doctor_prescriptions_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:toastification/toastification.dart';
import 'package:pdf/pdf.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final DoctorPrescriptionModel prescription;

  const PrescriptionDetailScreen({super.key, required this.prescription});
  Future<void> _printPrescription(BuildContext context) async {
    final pdf = pw.Document();
    final date = DateFormat.yMMMMd().add_jm().format(prescription.createDate);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text("Dr. ${prescription.doctorName}",
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Phone: ${prescription.doctorPhone}",
                      style: pw.TextStyle(fontSize: 16)),
                ],
              ),
            ),
            pw.Divider(),
            pw.Text("Patient Information",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text("Name: ${prescription.patientName}"),
            pw.Text("Age: ${prescription.patientAge}"),
            pw.Text("Gender: ${prescription.patientGender}"),
            pw.Text("Phone: ${prescription.patientPhone}"),
            pw.SizedBox(height: 16),
            pw.Text("Prescription Details",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text("Date: $date"),
            pw.Text("Prescription ID: ${prescription.sequenceId}"),
            pw.Text("Appointment ID: ${prescription.appointmentId}"),
            pw.Text(
                "Shift: ${prescription.shiftDay}, ${prescription.shiftTime}"),
            pw.SizedBox(height: 16),
            pw.Text("Medicines Prescribed",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            if (prescription.medicines.isEmpty)
              pw.Text("No medicines prescribed.")
            else
              ...prescription.medicines.map((med) => pw.Bullet(
                    text:
                        "${med.medicineName} - ${med.dosage}mg, ${med.frequency}, for ${med.duration} days",
                  )),
          ],
        ),
      ),
    );

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      toastification.show(
        context: context,
        title: const Text('Print Failed'),
        description: Text('Error: $e'),
        type: ToastificationType.error,
      );
    }
  }

  Future<void> _downloadPrescription(BuildContext context) async {
    final pdf = pw.Document();
    final date = DateFormat.yMMMMd().add_jm().format(prescription.createDate);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text("Dr. ${prescription.doctorName}",
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Phone: ${prescription.doctorPhone}",
                      style: pw.TextStyle(fontSize: 16)),
                ],
              ),
            ),
            pw.Divider(),
            pw.Text("Patient Information",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text("Name: ${prescription.patientName}"),
            pw.Text("Age: ${prescription.patientAge}"),
            pw.Text("Gender: ${prescription.patientGender}"),
            pw.Text("Phone: ${prescription.patientPhone}"),
            pw.SizedBox(height: 16),
            pw.Text("Prescription Details",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text("Date: $date"),
            pw.Text("Prescription ID: ${prescription.sequenceId}"),
            // pw.Text("Appointment ID: ${prescription.appointmentId}"),
            pw.Text(
                "Shift: ${prescription.shiftDay}, ${prescription.shiftTime}"),
            pw.SizedBox(height: 16),
            pw.Text("Medicines Prescribed",
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            if (prescription.medicines.isEmpty)
              pw.Text("No medicines prescribed.")
            else
              ...prescription.medicines.map((med) => pw.Bullet(
                    text:
                        "${med.medicineName} - ${med.dosage}mg, ${med.frequency}, for ${med.duration} days",
                  )),
          ],
        ),
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file =
          File("${output.path}/prescription_${prescription.sequenceId}.pdf");
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Prescription PDF',
      );
    } catch (e) {
      toastification.show(
        context: context,
        title: const Text('Download Failed'),
        description: Text('Error: $e'),
        type: ToastificationType.error,
      );
      print("❌ $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMMd().add_jm().format(prescription.createDate);
    final medicines = prescription.medicines;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Prescription"),
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.green),
        titleTextStyle: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Header
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Image.asset("assets/images/logo.jpg",
                            fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Dr. ${prescription.doctorName}",
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      Text(
                        "Phone: ${prescription.doctorPhone}",
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionHeader(Icons.person, "Patient Information"),
                const SizedBox(height: 8),
                _buildInfoRow("Name", prescription.patientName),
                _buildInfoRow("Age", "${prescription.patientAge}"),
                _buildInfoRow("Gender", prescription.patientGender),
                _buildInfoRow("Phone", prescription.patientPhone),
                const SizedBox(height: 20),
                _sectionHeader(Icons.description, "Prescription Details"),
                const SizedBox(height: 8),
                _buildInfoRow("Date", date),
                _buildInfoRow("Prescription ID", prescription.sequenceId),
                _buildInfoRow("Appointment ID", prescription.appointmentId),
                _buildInfoRow("Shift",
                    "${prescription.shiftDay}, ${prescription.shiftTime}"),
                const SizedBox(height: 20),
                _sectionHeader(Icons.medication, "Medicines Prescribed"),
                const SizedBox(height: 8),
                medicines.isEmpty
                    ? const Text("No medicines prescribed.",
                        style: TextStyle(color: Colors.redAccent))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: medicines.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, i) {
                          final med = medicines[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.circle,
                                size: 12, color: Colors.green),
                            title: Text(
                              med.medicineName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${med.dosage}mg, ${med.frequency}, for ${med.duration.toInt()} days",
                              style: const TextStyle(fontSize: 15),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 8),
                _sectionHeader(Icons.details, "Extra Details"),
                _buildInfoRow("Extra Details", prescription.extraDetails),

                const SizedBox(height: 32),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _downloadPrescription(context),
                      icon: const Icon(Icons.share),
                      label: const Text("Share as PDF"),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _printPrescription(context),
                      icon: const Icon(Icons.print),
                      label: const Text("Print"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
