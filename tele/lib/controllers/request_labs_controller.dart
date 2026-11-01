import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tele/controllers/labs_requested_controller.dart';
import 'package:tele/services/new_firebase_send_message.dart';
import 'package:tele/services/post_api_services.dart';
import 'package:toastification/toastification.dart';

class RequestLabsController extends GetxController {
  var isLoading = false.obs;

  Future<void> writeLabRequest({
    required List<Map<String,dynamic>> requestedLabs,
    required String patientId,
    required String doctorId,
    required String appointmentId,
    required String notes,
    required String doctorToken,
    required String patientToken,
  }) async {
    isLoading.value = true;


    final response = await ApiPostServices().writeLabRequest(
      requestedLabs: requestedLabs, 
      patientId: patientId, 
      doctorId: doctorId, 
      appointmentId: appointmentId, 
      notes: notes);
    
    isLoading.value = false;
    final title = "New Lab Request Issued";
    final body = "Your doctor has submitted a new lab request. Tap to view details.";
    // notify patient
    if(response['success'] == true){
      await NewFirebaseSendMessage().sendLabRequestNotificationToPatient(
       token: patientToken,
       title: title,
       body: body
     );
     await ApiPostServices()
          .saveNotifcation(title, body, '', patientId);
     // Refresh the prescription list
     final labsRequestedController = Get.put(LabsRequestedController());
     await labsRequestedController.getDoctorLabsRequest(patientId: patientId, doctorId: doctorId, appointmentId: appointmentId);
     
     toastification.show(
        context: Get.context!,
        title: const Text("Success"),
        description: Text(response['message']),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topRight,
        showProgressBar: true,
      );
      Get.back(); // Close modal/dialog
    } else {
      toastification.show(
        context: Get.context!,
        title: const Text("Error"),
        description: Text("Error: ${response['message']}"),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topRight,
        showProgressBar: true,
      );
    }
  } 
}