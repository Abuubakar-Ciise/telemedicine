import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tele/PrescriptionDetailScreen.dart';
import 'package:tele/controllers/doctor_prescription_controller.dart';
import 'package:tele/services/StorageService.dart';

class PrescriptionScreen extends StatefulWidget {
  final String patientId; 
  final String doctorId;
  final String appointmentId;
  const PrescriptionScreen({super.key,required this.patientId,required this.doctorId,required this.appointmentId});
  

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final DoctorPrescriptionController controller =
      Get.put(DoctorPrescriptionController());
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    Map<String, String?> userData = await StorageService.getUserData();
    userId = userData["userId"];
    setState(() {
      userId = userData["userId"] ?? "Unknown";
      controller.getPrescriptions(widget.doctorId,widget.appointmentId,widget.patientId);
      print("✅✅✅✅");
      print(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white, title: const Text("Prescriptions")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.prescriptions.isEmpty) {
          return const Center(child: Text("No prescriptions found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.prescriptions.length,
          itemBuilder: (context, index) {
            final item = controller.prescriptions[index];
            final date = DateFormat.yMMMMd().add_jm().format(item.createDate);
            final medicineCount = item.medicines?.length ?? 0;
            final summary = medicineCount > 0
                ? "$medicineCount medicine${medicineCount > 1 ? 's' : ''} prescribed"
                : "No medicines listed";

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PrescriptionDetailScreen(prescription: item),
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header row: Icon + Doctor name + Arrow
                      Row(
                        children: [
                          const Icon(Icons.medical_services,
                              color: Colors.blue, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Dr. ${item.doctorName}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// Patient
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 18, color: Colors.green),
                          const SizedBox(width: 6),
                          Text("Patient: ${item.patientName}",
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),

                      /// Date
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Colors.orange),
                          const SizedBox(width: 6),
                          Text("Date: $date",
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),

                      /// Medicine Summary
                      Row(
                        children: [
                          const Icon(Icons.list_alt,
                              size: 18, color: Colors.purple),
                          const SizedBox(width: 6),
                          Text(summary, style: const TextStyle(fontSize: 14)),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// Call-to-action
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            "Tap to view full prescription",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
