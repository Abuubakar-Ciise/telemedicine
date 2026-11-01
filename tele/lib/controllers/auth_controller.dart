import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/services/auth_services.dart';
import 'package:tele/services/get_api_services.dart';
import 'package:tele/views/screens/auth/login_screen.dart';
import 'package:toastification/toastification.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isLoggIn = false.obs;

  Future<void> registerPatient(
      String name,
      String email,
      String address,
      String gender,
      int age,
      String phone,
      String username,
      String password) async {
    try {
      isLoading.value = true;
      final response = await AuthServices.registerPatient(
          name, email, address, gender, age, phone, username, password);
      if (response['success']) {
        Get.snackbar("Success", "Account created! Please login.");
        Get.offAll(() => LoginScreen());
      } else {
        Get.snackbar(
            "Error", response['message'] ?? "An unknown error occurred");
      }
    } catch (e) {
      Get.snackbar("Error", "Could not create the account: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Login Docator an datient

  Future<void> loginDoctorAndPatient(
      String email, String password, String token) async {
    try {
      isLoading.value = true;
      final response =
          await AuthServices.loginDoctorAndPatient(email, password, token);

      if (response['success'] == true) {
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          title: Text('Success'),
          description: Text(response['message']),
          autoCloseDuration: const Duration(seconds: 3),
          animationDuration: const Duration(milliseconds: 300),
          alignment: Alignment.topRight,
          showProgressBar: true,
        );
        isLoggIn.value = true;
        // Get.offNamed('/mainscreen');
        if (response['type'] == 1) {
          Map<String, String?> userData = await StorageService.getUserData();
          final userId = userData["userId"]; // <- however you store it
          if (userId != null) {
            await ApiGetServices.updateFcmToken(userId);
          }
          
          Get.offNamed('/mainscreen');
        } else {
          Map<String, String?> userData = await StorageService.getUserData();
          final userId = userData["userId"]; // <- however you store it
          if (userId != null) {
            await ApiGetServices.updateFcmToken(userId);
          }
          Get.offNamed('/doctormainscreen');
        }
      } else {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          title: Text('Error'),
          description: Text(response['message']),
          autoCloseDuration: const Duration(seconds: 3),
          animationDuration: const Duration(milliseconds: 300),
          alignment: Alignment.topRight,
          showProgressBar: true,
        );
      }
    } catch (e) {
      toastification.show(
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
        title: Text('Login failed'),
        description: Text('Could not log in: $e'),
        autoCloseDuration: const Duration(seconds: 3),
        animationDuration: const Duration(milliseconds: 300),
        alignment: Alignment.topRight,
        showProgressBar: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
