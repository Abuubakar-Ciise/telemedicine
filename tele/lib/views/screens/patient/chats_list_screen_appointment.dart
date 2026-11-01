import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:tele/controllers/appoinments_controller.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/views/screens/components/patient_appointment_card.dart';
import 'package:tele/views/screens/loading_message_screen.dart';

class ChatsListScreenAppointment extends StatefulWidget {
  const ChatsListScreenAppointment({super.key});

  @override
  State<ChatsListScreenAppointment> createState() => _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<ChatsListScreenAppointment> {
  final appoinmentsController = Get.put(AppoinmentsController());
  String? userId;
  @override
  void initState() {
    super.initState();
    loadUserData();

  }
  Future<void> loadUserData() async {
    Map<String, String?> userData = await StorageService.getUserData();
    setState(() {
      userId = userData["userId"] ?? "Unknown";
      appoinmentsController.fechtAppointments(userId!);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'My Treatment'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Use GetX navigation to go back
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              // If can't go back, navigate to home screen
              Get.offAllNamed('/mainscreen');
            }
          },
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if(appoinmentsController.isLoading.value){
            return LoadingMessage();
          }
          if(appoinmentsController.appointments.isEmpty){
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Appointments Found".tr(),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You don't have any treatment appointments yet".tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: appoinmentsController.appointments.length,
            // itemCount: 5,
            itemBuilder: (context,index) {
              final appointment = appoinmentsController.appointments[index];
              // final hasMultiple = appoinmentsController.hasMultipleAppointments(appointment.patientToken);
              print('for doctor ${appointment.doctorToken} -- ${appointment.id}');
              print('for pateint ${appointment.patientToken} -- ${appointment.id}');
              print("APPOINTMENT STATUS: ${appointment.status}");
              return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: PatientAppointmentCard(
                  appointmentTime: appointment.shiftTime, 
                  appointmentDate: appointment.appointmentDate, 
                  doctorName: appointment.doctorName, 
                  patientName: appointment.patientName, 
                  patientProfile: appointment.doctorProfile,
                  doctorToken: appointment.doctorToken,
                  patientToken: appointment.patientToken,
                  doctorPhone: appointment.doctorPhone,
                  patientPhone: appointment.patientPhone,
                  id: appointment.id,
                  doctorId: appointment.doctorId,
                  patientId:appointment.patientId ,
                  status: appointment.status,
                  isReviewed: appointment.isReviewed
                  // /status: appointment.status
                  ),
                );
            });
        }),
      ),
    );
  }
}