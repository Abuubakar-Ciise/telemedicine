import 'package:get/get.dart';
import 'package:tele/Models/patient_appointements_model.dart';
import 'package:tele/services/get_api_services.dart';

class AppoinmentsController extends GetxController {
  var isLoading = false.obs;
  var appointments = <PatientAppointementsModel>[].obs;
  var labsAppointments = <PatientAppointementsModel>[].obs;

  Future<void> fechtAppointments(String patientId) async {
    // Change return type to Future<void>
    try {
      isLoading.value = true;
      final response = await ApiGetServices.patientAppointements(patientId);
      // appointmets.assignAll(response.where((st) => st.status == 1));
      appointments.assignAll(response.where((a) => a.status != 3 && a.status != 7).toList());
      labsAppointments.assignAll(response.where((a) => a.status != 3 && a.status != 7 && a.status != 2).toList());
    } catch (e) {
      print("Error fetching hospitals: $e");
      //  return [];
    } finally {
      isLoading.value = false;
    }
  }
//   Future<void> fechtAppointments(String patientId) async {
//   try {
//     isLoading.value = true;
//     final response = await ApiGetServices.patientAppointements(patientId);
//     print("response $response");

//     // Step 1: Filter out unwanted statuses
//     final filtered = response.where((a) => a.status != 3 && a.status != 7).toList();
//     print("filtered $filtered");

//     final Map<String, PatientAppointementsModel> latestAppointments = {};

//     for (var appointment in filtered) {
//       final existing = latestAppointments[appointment.doctorId];

//       if (existing != null) {
//         // Priority logic:
//         // If current appointment status is 4, override existing
//         if (appointment.status == 4) {
//           latestAppointments[appointment.doctorId] = appointment;
//           continue;
//         }

//         // If existing is status 4, keep it
//         if (existing.status == 4) {
//           continue;
//         }

//         // Same status — no date/time comparison, so just keep existing
//         if (appointment.status == existing.status) {
//           continue;
//         } else {
//           // Status priority: 1 (in progress) > 2 (completed)
//           if (appointment.status == 1 && existing.status == 2) {
//             latestAppointments[appointment.doctorId] = appointment;
//           }
//           // If existing is 1 and current is 2, keep existing (do nothing)
//         }
//       } else {
//         // No existing appointment for doctor, add current
//         latestAppointments[appointment.doctorId] = appointment;
//       }
//     }

//     appointments.assignAll(latestAppointments.values.toList());
//   } catch (e) {
//     print("Error fetching appointments: $e");
//   } finally {
//     isLoading.value = false;
//   }
// }





  // Future<void> fechtAppointments(String patientId) async {
  //   // Change return type to Future<void>
  //   try {

  //     isLoading.value = true;
  //     final response = await ApiGetServices.patientAppointements(patientId);
  //     // appointmets.assignAll(response.where((st) => st.status == 1));
  //     appointments.assignAll(response.where((a) => a.status != 3 && a.status != 2).toList()
  //       ..sort((a, b) {
  //         // Custom sorting logic for status codes
  //         if (a.status == 1) return -1; // Ensure '4' comes first
  //         if (b.status == 1) return 1;
  //         if (a.status == 4) return -1; // Ensure '2' comes second
  //         if (b.status == 4) return 1;
  //         return a.status.compareTo(b.status); // Sort remaining statuses
  //       }));
  //   } catch (e) {
  //     print("Error fetching hospitals: $e");
  //     //  return [];
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
