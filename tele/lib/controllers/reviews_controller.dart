import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tele/services/post_api_services.dart';
import 'package:toastification/toastification.dart';

class ReviewsController extends GetxController{
  var isLoading = false.obs;


  Future<void> feedbackPatient(
      String comments,
      String doctorId,
      String patientId,
      String appointmentId,
      double rating) async {
    try {
      isLoading.value = true;
      final response = await ApiPostServices().feedbackPatient(comments, doctorId, patientId, rating,appointmentId);
      toastification.show(
        type: response['success']
            ? ToastificationType.success
            : ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text(response['success'] ? 'Success' : 'error'),
        description: Text(response['message']),
        autoCloseDuration: const Duration(seconds: 3),
        // animationDuration: const Duration(milliseconds: 300),
        alignment: Alignment.topRight,
        showProgressBar: true,
      );
      Get.back();
    } catch (e) {
      toastification.show(
        type: ToastificationType.error, // Fixing incorrect toast type
        style: ToastificationStyle.flat,
        title: Text('Error'), // Fixed incorrect conditional syntax
        description: Text(e.toString()), // Displaying the caught exception
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.topRight,
        showProgressBar: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}