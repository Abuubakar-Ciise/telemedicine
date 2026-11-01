import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tele/Models/adds_model.dart';
import 'package:tele/Models/doctor_appointements_model.dart';
import 'package:tele/Models/doctor_prescriptions_model.dart';
import 'package:tele/Models/doctor_transection_model.dart';
import 'package:tele/Models/doctors_list_nodel.dart';
import 'package:tele/Models/hospital_model.dart';
import 'package:tele/Models/lab_report_model.dart';
import 'package:tele/Models/lab_request_Model.dart';
import 'package:tele/Models/patient_appointements_model.dart';
import 'package:tele/Models/self_managment_models.dart';
import 'package:tele/Models/shift_model.dart';
import 'package:tele/Models/specialist_model.dart';
import 'package:tele/Models/transection_model.dart';
import 'package:tele/views/screens/components/config.dart';

class ApiGetServices {
  static String get url => Config.baseUrl;

  // get List of Hospitals
  Future<List<Hospital>> fetchHospitals() async {
    try {
      final response = await http.post(Uri.parse('$url/getAll_Hospitals'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['record'] as List)
              .map((hospital) => Hospital.fromJson(hospital))
              .toList();
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Fetch Error: $e");
      return [];
    }
  }

  // get specialist
  Future<List<SpecialistModel>> fetchSpecialist() async {
    try {
      final response = await http.post(Uri.parse('$url/getAll_Speciality'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['record'] as List)
              .map((hospital) => SpecialistModel.fromJson(hospital))
              .toList();
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Fetch Error: $e");
      return [];
    }
  }

  // get list of dectors
  Future<List<DoctorList>> fechDoctorsList() async {
    try {
      final response = await http.post(Uri.parse('$url/getAll_Doctors'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['record'] as List)
              .map((doctor) => DoctorList.fromJson(doctor))
              .toList();
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }

  // get filter_Hospital;
  Future<List<DoctorList>> filterHospital(String hospitalId) async {
    try {
      final response = await http.post(Uri.parse('$url/filter_Hospital'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "hospital_id": hospitalId,
          }));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['record'] as List)
              .map((doctor) => DoctorList.fromJson(doctor))
              .toList();
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }

  // get filter_Speciality
  Future<List<DoctorList>> filterSpeciality(String hospitalId) async {
    try {
      final response = await http.post(Uri.parse('$url/filter_Speciality'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "speciality_id": hospitalId,
          }));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['record'] as List)
              .map((doctor) => DoctorList.fromJson(doctor))
              .toList();
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }
  // Future<Map<String, List<Shift>>> fetchShiftsEasy(String doctorId,String appointmentDate, String dayName) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/$dayName'),
  //        headers: {
  //       "Content-Type": "application/json", // Ensure the request is sent as JSON
  //     },
  //     body: json.encode({
  //       "doctor_id": doctorId, // Passing the doctor_id in the request body
  //       "appointment_date": appointmentDate
  //     }),
  //       );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       if (data["success"] == true) {
  //         Map<String, List<Shift>> shiftsByDay = {};

  //         // Loop through the response keys (days of the week)
  //         data.forEach((key, value) {
  //           if (key != "success" && key != "message") {
  //             shiftsByDay[key] = (value as List)
  //                 .map((shift) => Shift.fromJson(shift))
  //                 .toList();
  //           }
  //         });

  //         return shiftsByDay;
  //       } else {
  //         throw Exception("Failed to fetch shifts");
  //       }
  //     } else {
  //       throw Exception("Failed to load shifts: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     throw Exception("Error: $e");
  //   }
  // }

  Future<Map<String, List<Shift>>> fetchShiftsEasy(
      String doctorId, String appointmentDate, String dayName) async {
    try {
      final response = await http.post(
        Uri.parse('$url/${dayName}_Shifts'),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "doctor_id": doctorId,
          "appointment_date": appointmentDate,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true) {
          Map<String, List<Shift>> shiftsByDay = {};

          // Iterate over the 'shifts' object in the response
          data["shifts"].forEach((key, value) {
            if (value is List) {
              // Process the shift data and map to Shift objects
              shiftsByDay[key] = (value as List)
                  .map((shift) => Shift.fromJson(shift))
                  .toList();
            } else {
              print("Unexpected format for key $key: $value");
            }
          });

          return shiftsByDay;
        } else {
          throw Exception("Failed to fetch shifts");
        }
      } else {
        throw Exception("Failed to load shifts: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // check shifts
  static Future<Map<String, dynamic>> checkShifts(
      String shiftsId, String appointmentDate) async {
    try {
      final response = await http.post(
        Uri.parse('$url/check_shifts'),
        headers: {'content-Type': 'application/json'},
        body: jsonEncode(
            {'shifts_id': shiftsId, 'appointment_date': appointmentDate}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          'success': responseBody['success'],
          'message': responseBody['message']
        };
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseBody['message'] ?? "unknow error occurred"
        };
      }
    } catch (e) {
      print('Error check shifts $e');
      return {'success': false, 'message': "failed to connect to server"};
    }
  }
  // patient Appointements

  static Future<List<PatientAppointementsModel>> patientAppointements(
      String patientId) async {
    try {
      final response = await http.post(
          // Uri.parse('$url/patient_appointements'),
          Uri.parse('$url/patient_appointements'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"patient_id": patientId}));
      if (response.statusCode == 200) {
        final record = jsonDecode(response.body);
        print("✅✅✅ ${response.body}");
        if (record['success']) {
          return (record['record'] as List)
              .map((appointments) =>
                  PatientAppointementsModel.fromJson(appointments))
              .toList();
        } else {
          throw Exception("API Error: ${record['message']}");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }

  // doctor Appointements
  static Future<List<DoctorAppointementsModel>> doctorAppointements(
      String doctorId) async {
    try {
      final response = await http.post(
          // Uri.parse('$url/patient_appointements'),
          Uri.parse('$url/doctor_appointements'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"doctor_id": doctorId}));
      if (response.statusCode == 200) {
        final record = jsonDecode(response.body);
        if (record['success']) {
          return (record['record'] as List)
              .map((appointments) =>
                  DoctorAppointementsModel.fromJson(appointments))
              .toList();
        } else {
          throw Exception("API Error: ${record['message']}");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }

  // patient Transection
  static Future<List<PatientTransectionModel>> patientTransection(
      String patientId) async {
    try {
      final response = await http.post(Uri.parse('$url/patient_transection'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"patient_id": patientId}));

      if (response.statusCode == 200) {
        final record = jsonDecode(response.body);
        if (record['success']) {
          return (record['record'] as List)
              .map((appointments) =>
                  PatientTransectionModel.fromJson(appointments))
              .toList();
        } else {
          throw Exception("API Error: ${record['message']}");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }

  // doctor Transection
  static Future<List<DoctorTransectionModel>> doctorTransection(
      String patientId) async {
    try {
      final response = await http.post(Uri.parse('$url/doctor_transection'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"doctor_id": patientId}));

      if (response.statusCode == 200) {
        final record = jsonDecode(response.body);
        if (record['success']) {
          return (record['record'] as List)
              .map((appointments) =>
                  DoctorTransectionModel.fromJson(appointments))
              .toList();
        } else {
          throw Exception("API Error: ${record['message']}");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      return [];
    }
  }
  // adds Api

  static Future<List<AddsModel>> adds() async {
    try {
      final response = await http.post(Uri.parse('$url/adds'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          return (data['record'] as List)
              .map((adds) => AddsModel.fromJson(adds))
              .toList();
        } else {
          final data = jsonDecode(response.body);
          throw Exception("API Error: ${data['message']}");
        }
      }
      throw Exception("Server Error: ${response.statusCode}");
    } catch (e) {
      return [];
    }
  }

  // selfmanagment

  Future<List<SelfManagmentModels>> selfManagment() async {
    try {
      final response = await http.post(Uri.parse('$url/selfmanagment'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['record'] as List)
              .map((self) => SelfManagmentModels.fromJson(self))
              .toList();
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      }
      throw Exception("Server Error: ${response.statusCode}");
    } catch (e) {
      return [];
    }
  }
  // update FCM Token

  static Future<void> updateFcmToken(String userId) async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    try {
      final String? token = await _firebaseMessaging.getToken().timeout(const Duration(seconds: 15));
      if (token != null) {
        final response = await http.post(
          Uri.parse('$url/update_token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"_id": userId, "token": token}),
        );

        if (response.statusCode == 200) {
          print("✅ FCM TOKEN updated successfully");
          // await StorageService.updateUserField('auth_token', token);
          // Save token
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          print("✅✅✅ $token");
          print("--------");
          final userToken = await Config.getUserToken();
          print("✅✅✅✅✅ $userToken");
        } else {
          print('❌ Failed to update token: ${response.statusCode}');
        }
      } else {
        print('❌ FCM token is null');
      }
    } catch (e) {
      print('🔥 Error updating FCM token: $e');
    }
  }

  //doctor Prescrptions reading
  Future<List<DoctorPrescriptionModel>> getPrescriptions(
    String doctorId,
    String pateintId,
    String appointmentId
    ) async {
    try {
      final response = await http.post(Uri.parse('$url/doctor_prescriptions'),
          headers: {'content-Type': 'application/json'},
          body: jsonEncode(
            {
              "doctor_id": doctorId,
              "patient_id": pateintId,
              "appointment_id": appointmentId
            }));
      print("✅✅✅✅ doctor_prescriptions");
      print("$doctorId");
      print("$pateintId");
      print("$appointmentId");
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['record'] as List)
              .map((prescription) =>
                  DoctorPrescriptionModel.fromJson(prescription))
              .toList();
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      }
      throw Exception("Server Error: ${response.statusCode}");
    } catch (e) {
      return [];
    }
  }

  //doctor Prescrptions reading
  Future<List<DoctorPrescriptionModel>> getPatientPrescriptions(
      String patientId, String doctorId) async {
    try {
      final response = await http.post(Uri.parse('$url/patient_prescriptions'),
          headers: {'content-Type': 'application/json'},
          body: jsonEncode({"patient_id": patientId, "doctor_id": doctorId}));
      print("✅✅✅✅");
      print("dcotor x patient id ${doctorId}   --- ${patientId}");
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['record'] as List)
              .map((prescription) =>
                  DoctorPrescriptionModel.fromJson(prescription))
              .toList();
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      }
      throw Exception("Server Error: ${response.statusCode}");
    } catch (e) {
      return [];
    }
  }


  // LabReportModel APi
  Future<List<LabReportModel>> labsReports(
      String patientId, String doctorId, String appointmentId) async {
    try {
      final response = await http.post(Uri.parse('$url/patient_labs'),
          headers: {'content-Type': 'application/json'},
          body: jsonEncode({
            "patient_id": patientId,
            "doctor_id": doctorId,
            "appointment_id": appointmentId
          }));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['record'] != null) {
          List records = data['record'];
          return records.map((e) => LabReportModel.fromJson(e)).toList();
        } else {
          throw Exception('Failed to load lab reports: ${data['message']}');
        }
      } else {
        throw Exception(
            'Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching lab reports: $e');
    }
  }

  //patient_LabRequest
  Future<List<LabRequestModel>> patientLabRequest({
    required String patientId,
    required String doctorId,
    required String appointmentId
  }) async {
    try {
      final response = await http.post(Uri.parse('$url/patient_LabRequest'),
      headers: {'content-Type': 'application/json'},
      body: jsonEncode({
         "patient_id": patientId,
        "doctor_id": doctorId,
        "appointment_id": appointmentId
      })
      );
      print("✅✅✅✅");
      print("dcotor x patient x appioinment id ${doctorId}   --- ${patientId} -- ${appointmentId}");
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['record'] as List)
              .map((prescription) =>
                  LabRequestModel.fromJson(prescription))
              .toList();
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      }
      throw Exception("Server Error: ${response.statusCode}");
    } catch (e) {
      print("error from patient_LabRequest $e");
      return [];
    }
  }

  ///doctor_LabRequest

  Future<List<LabRequestModel>> doctorLabRequest({
    required String patientId,
    required String doctorId,
    required String appointmentId
  }) async {
    try {
      final response = await http.post(Uri.parse('$url/doctor_LabRequest'),
      headers: {'content-Type': 'application/json'},
      body: jsonEncode({
         "patient_id": patientId,
        "doctor_id": doctorId,
        "appointment_id": appointmentId
      })
      );
      print("✅✅✅✅");
      print("dcotor x patient x appioinment id ${doctorId}   --- ${patientId} -- ${appointmentId}");
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['record'] as List)
              .map((prescription) =>
                  LabRequestModel.fromJson(prescription))
              .toList();
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      }
      throw Exception("Server Error: ${response.statusCode}");
    } catch (e) {
      print("error from patient_LabRequest $e");
      return [];
    }
  }

  // // get patient_notification
  // Future<List<PatientNotification>> patientNotification(String patientId) async {
  //   try {
  //     final response = await http.post(Uri.parse('$url/patient_notification'),
  //     headers: {'content-Type': 'application/json'},
  //     body: jsonEncode({
  //       "patient_id": patientId
  //     })
  //     );
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data['success']) {
  //         return (data['record'] as List)
  //             .map((hospital) => PatientNotification.fromJson(hospital))
  //             .toList();
  //       } else {
  //         throw Exception("API Error: ${data['message']}");
  //       }
  //     } else {
  //       throw Exception("Server Error: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Fetch Error: $e");
  //     return [];
  //   }
  // }
  //   // get doctor_notification
  // Future<List<DoctorNotification>> doctorNotification(String doctorId) async {
  //   try {
  //     final response = await http.post(Uri.parse('$url/doctor_notification'),
  //     headers: {'content-Type': 'application/json'},
  //     body: jsonEncode({
  //       "doctor_id": doctorId
  //     })
  //     );
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data['success']) {
  //         return (data['record'] as List)
  //             .map((hospital) => DoctorNotification.fromJson(hospital))
  //             .toList();
  //       } else {
  //         throw Exception("API Error: ${data['message']}");
  //       }
  //     } else {
  //       throw Exception("Server Error: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Fetch Error: $e");
  //     return [];
  //   }
  // }
  // update way 
  Future<List<T>> fetchNotification<T>({
    required String userId,
    required String userType, // 'doctor' or 'patient'
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final endpoint = userType == 'patient'
        ? '$url/patient_notification'
        : '$url/doctor_notification';

    final body = userType == 'patient'
        ? {'patient_id': userId}
        : {'doctor_id': userId};

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['record'] as List).map((e) => fromJson(e)).toList();
        } else {
          throw Exception("API Error: ${data['message']}");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Fetch Error: $e");
      return [];
    }
  }

}
