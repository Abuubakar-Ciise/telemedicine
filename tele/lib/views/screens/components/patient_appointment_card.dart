import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tele/controllers/doctor_list_controller.dart';
import 'package:tele/controllers/re_appointment_controller.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/views/screens/patient/patient_appointment_chat_screen.dart';

class PatientAppointmentCard extends StatelessWidget {
  final String appointmentTime;
  final String appointmentDate;
  final String doctorName;
  final String patientName;
  final String patientProfile;
  final String doctorToken;
  final String patientToken;
  final String doctorPhone;
  final String patientPhone;
  final String id;
  // final bool hasMultipleAppointments;
  final String doctorId;
  final String patientId;
  final int status;
  final String isReviewed;

  const PatientAppointmentCard({
    super.key,
    required this.appointmentTime,
    required this.appointmentDate,
    required this.doctorName,
    required this.patientName,
    required this.patientProfile,
    required this.doctorToken,
    required this.patientToken,
    required this.doctorPhone,
    required this.patientPhone,
    required this.id,
    // required this.hasMultipleAppointments,
    required this.doctorId,
    required this.patientId,
    required this.status,
    required this.isReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final doctorListController = Get.put(DoctorListController());
    final reAppointmentController = Get.put(ReAppointmentController());

    DateTime appointmentDateTime;
    try {
      appointmentDateTime = DateTime.parse(appointmentDate);
    } catch (e) {
      appointmentDateTime = DateFormat('dd MMMM yyyy').parse(appointmentDate);
    }

    String formattedDate =
        DateFormat('EEE, dd MMM yyyy').format(appointmentDateTime);
    final url = Config.baseUrl;
    print("STATUS: $status");

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // Top part with patient info
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientAppointmentChatScreen(
                          id: id,
                          patientName: doctorName,
                          doctorName: doctorName,
                          patientProfile: patientProfile,
                          doctorToken: doctorToken,
                          patientToken: patientToken,
                          doctorPhone: doctorPhone,
                          patientPhone: patientPhone,
                          doctorId: doctorId,
                          patientId: patientId,
                          status: status,
                          isReviewed: isReviewed,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: (patientProfile.isNotEmpty &&
                                    patientProfile != "N/A")
                                ? NetworkImage('$url/$patientProfile')
                                : const AssetImage('assets/default_image.png')
                                    as ImageProvider,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctorName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 16, color: Colors.redAccent),
                                  const SizedBox(width: 5),
                                  Text(
                                    appointmentTime,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 16, color: Colors.blueGrey),
                                  const SizedBox(width: 5),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              // if (hasMultipleAppointments)
                              //   const Padding(
                              //     padding: EdgeInsets.only(top: 4),
                              //     child: Text(
                              //       "Multiple Appointments",
                              //       style: TextStyle(
                              //         fontSize: 12,
                              //         color: Colors.orange,
                              //         fontWeight: FontWeight.w500,
                              //       ),
                              //     ),
                              //   ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // const Divider(height: 0.5, thickness: 0.5, color: Colors.grey),
              // const Divider(height: 0.5, thickness: 0.5, color: Colors.grey),

              // Buttons
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       Expanded(
              //         child: Material(
              //           color: Colors.transparent,
              //           child: InkWell(
              //             borderRadius: BorderRadius.circular(8),
              //             onTap: () {
              //               print('Re-Appointment button clicked');
              //               showModalBottomSheet(
                              
              //                 context: context,
              //                 isScrollControlled: true, // important
              //                 // backgroundColor: Colors.transparent,
              //                 backgroundColor: Colors.white,
              //                 builder: (context) => ReviewsScreen(
              //                   doctorId: doctorId,
              //                   patientId: patientId,
              //                 ),
              //               );
              //             },
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(vertical: 9),
              //               decoration: BoxDecoration(
              //                 color: Colors.green,
              //                 borderRadius: BorderRadius.circular(8),
              //               ),
              //               child: const Center(
              //                 child: Text(
              //                   'Re-Appointment',
              //                   style: TextStyle(
              //                     color: Colors.white,
              //                     fontSize: 13,
              //                     fontWeight: FontWeight.w500,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),

        // --- This is the special "Re-Appointment" Badge ---

        if (status == 4)
          Positioned(
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: const Text(
                "Re-Appointment",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        if (status == 1)
          Positioned(
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: const Text(
                "In Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        if (status == 2)
          Positioned(
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: const Text(
                "Completed",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ConfirmCompleteBottomSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  const ConfirmCompleteBottomSheet({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: const [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  "Complete Appointment",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Body Section
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              "Are you sure you want to complete this appointment? This action cannot be undone.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    onConfirm(); // Call confirm function
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
