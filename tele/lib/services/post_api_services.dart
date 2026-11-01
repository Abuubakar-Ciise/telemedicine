import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tele/views/screens/components/config.dart';

class ApiPostServices {
  static String get url => Config.baseUrl;

  Future<Map<String, dynamic>> bookAndPay(
      String doctorId,
      String patientId,
      String shiftsId,
      String senderPhone,
      String reciverPhone,
      double amount,
      String appointmentDate,
      String reason) async {
    try {
      final response = await http.post(Uri.parse('$url/bookAndPay'),
          // headers: {'Content-Type': 'application/json'},
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "doctor_id": doctorId,
            "patient_id": patientId,
            "shifts_id": shiftsId,
            "sender_phone": senderPhone,
            "reciver_phone": reciverPhone,
            "amount": amount,
            "appointment_date": appointmentDate,
            "reason": reason
          }));
      print("Api format ${'$url/bookAndPay'}");
      print(
          "Resonponse body ${response.body} and statusCode ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          "success": responseBody['success'],
          "message": responseBody['message']
        };
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Response is not JSON: ${response.body}");
        return {
          "success": false,
          "message": responseBody['message'] ?? "Unknown error occurred",
        };
      }
    } catch (e) {
      print("Error from bookAndPay $e");
      return {"success": false, "message": "Failed to connect to server"};
    }
  }

  // re-Appointment

  Future<Map<String, dynamic>> reAppointment(String appointmentDate,
      String shiftsId, String appointmentId, int status) async {
    try {
      final response = await http.post(Uri.parse('$url/re_appointment'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "appointment_date": appointmentDate,
            "shifts_id": shiftsId,
            "_id": appointmentId,
            "status": status
          }));

      if (response.statusCode == 200) {
        print("🚀🚀🚀🚀🚀${response.body}");
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("❌ ${responseBody}");
        return {
          "success": responseBody['success'],
          "message": responseBody['message']
        };
      } else {
        print("🚀🚀🚀🚀🚀${response.body}");
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Response is not JSON: ${response.body}");
        print("❌ ${responseBody}");
        return {
          "success": false,
          "message": responseBody['message'] ?? "Unknown error occurred",
        };
      }
    } catch (e) {
      print("Error from bookAndPay $e");
      return {"success": false, "message": "Failed to connect to server"};
    }
  }

  // save_prescription
  Future<Map<String, dynamic>> writePrescription({
    required String patientId,
    required String doctorId,
    required String appointmentId,
    required String extraDetail,
    required List<Map<String, dynamic>> medicines,
  }) async {
    try {
      final response = await http.post(Uri.parse('$url/save_prescription'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "patient_id": patientId,
            "doctor_id": doctorId,
            "appointment_id": appointmentId,
            "extra_detail": extraDetail,
            "medicines": medicines,
          }));
      print("✅✅✅");
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          "success": responseBody['success'],
          "message": responseBody['message']
        };
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Response is not JSON: ${response.body}");
        return {
          "success": false,
          "message": responseBody['message'] ?? "Unknown error occurred",
        };
      }
    } catch (e) {
      print("error from writePrescription $e");
      return {"success": false, "message": "Failed to connect to server"};
    }
  }

  /// feedbackPatient
  Future<Map<String, dynamic>> feedbackPatient(String comments, String doctorId,
      String patientId, double rating, String appointmentId) async {
    try {
      final response = await http.post(Uri.parse('$url/feedbackPatient'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "comments": comments,
            "doctor_id": doctorId,
            "patient_id": patientId,
            "appointment_id": appointmentId,
            "rating": rating
          }));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          "success": responseBody['success'],
          "message": responseBody['message']
        };
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Response is not JSON: ${response.body}");
        return {
          "success": false,
          "message": responseBody['message'] ?? "Unknown error occurred",
        };
      }
    } catch (e) {
      print("error from writePrescription $e");
      return {"success": false, "message": "Failed to connect to server"};
    }
  }

  // save_labs_record
  // Future<Map<String, dynamic>> saveLabsRecord({
  //   required String patientId,
  //   required String doctorId,
  //   required String appointmentId,
  //   required String imagePath,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$url/save_labs_record'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         "patient_id": patientId,
  //         "doctor_id": doctorId,
  //         "appointment_id": appointmentId,
  //         "report_url": imagePath,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       return {
  //         'success': false,
  //         'message': 'Failed to save labs record. Status: ${response.statusCode}'
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'success': false,
  //       'message': 'Error saving labs record: $e'
  //     };
  //   }
  // // }
  // Future<Map<String, dynamic>> saveLabsRecordWithFile({
  //   required String patientId,
  //   required String doctorId,
  //   required String appointmentId,
  //   required File imageFile,
  // }) async {
  //   try {
  //     final uri = Uri.parse('$url/save_labs_record');
  //     final request = http.MultipartRequest('POST', uri);

  //     // Add file
  //     request.files.add(
  //       await http.MultipartFile.fromPath('file', imageFile.path),
  //     );

  //     // Add fields
  //     request.fields['patient_id'] = patientId;
  //     request.fields['doctor_id'] = doctorId;
  //     request.fields['appointment_id'] = appointmentId;

  //     final response = await request.send();
  //     final resBody = await http.Response.fromStream(response);

  //     if (response.statusCode == 200) {
  //       return {
  //         'success': true,
  //         'body': resBody.body,
  //       };
  //     } else {
  //       return {
  //         'success': false,
  //         'message': 'HTTP ${response.statusCode}: ${resBody.body}',
  //       };
  //     }
  //   } catch (e) {
  //     return {
  //       'success': false,
  //       'message': 'Exception: $e',
  //     };
  //   }
  // }
  Future<Map<String, dynamic>> saveLabsRecordWithFile({
  required String patientId,
  required String doctorId,
  required String appointmentId,
  required File imageFile,
}) async {
  try {
    final uri = Uri.parse('$url/save_labs_record');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path), // Confirm key name with backend
    );

    request.fields['patient_id'] = patientId;
    request.fields['doctor_id'] = doctorId;
    request.fields['appointment_id'] = appointmentId;

    final response = await request.send();
    final resBody = await http.Response.fromStream(response);
    final responseJson = jsonDecode(resBody.body);

    print("📦 Upload Response Body: ${resBody.body}");

    if (response.statusCode == 200 && responseJson['success'] == true) {
      return {
        'success': true,
        'data': responseJson['data'] ?? {},
        'message': responseJson['message'] ?? 'Upload success',
      };
    } else {
      return {
        'success': false,
        'message': responseJson['message'] ?? 'Upload failed',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Exception: $e',
    };
  }
}


  // updateProfilePicture
  Future<Map<String, dynamic>> updateProfilePicture(
      {required String id, required File imageFile}) async {
    try {
      final uri = Uri.parse('$url/updateProfile');
      final request = http.MultipartRequest("POST", uri);
      // Add the image file
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      request.fields['patient_id'] = id;
      final response = await request.send();
      final resBody = await http.Response.fromStream(response);
      print("✅✅✅");
      print("${resBody.body} && $response");
      print("✅✅✅");

      if (response.statusCode == 200) {
        final data = jsonDecode(resBody.body);
        return {
          'success': data['success'],
          'message': data['message'] ?? 'Profile picture updated.',
          'picture': data['picture'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode} – ${resBody.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Exception: $e',
      };
    }
  }

  //change Passowrd
  Future<Map<String, dynamic>> changePassword(String id, String exPassWord,
      String newPassword, String confirmPassword) async {
    try {
      final response = await http.post(
          Uri.parse(
            "$url/changesPassword",
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "id": id,
            "PassWord": exPassWord,
            "newPassword": newPassword,
            "confirmPassword": confirmPassword
          }));
      print("${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          "success": responseBody['success'],
          "message": responseBody['message']
        };
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Response is not JSON: ${response.body}");
        return {
          "success": false,
          "message": responseBody['message'] ?? "Unknown error occurred",
        };
      }
    } catch (e) {
      print("errror from changePassword $e");
      return {"success": false, "message": "Failed to connect to server"};
    }
  }

  //save_LabRequest
  Future<Map<String, dynamic>> writeLabRequest({
    required List<Map<String, dynamic>> requestedLabs,
    required String patientId,
    required String doctorId,
    required String appointmentId,
    required String notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$url/save_LabRequest"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "requested_tests": requestedLabs,
          "patient_id": patientId,
          "doctor_id": doctorId,
          "appointment_id": appointmentId,
          "notes": notes
        }),
      );
      print("✅✅✅ /save_LabRequest");
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          "success": responseBody['success'],
          "message": responseBody['message']
        };
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Response is not JSON: ${response.body}");
        return {
          "success": false,
          "message": responseBody['message'] ?? "Unknown error occurred",
        };
      }
    } catch (e) {
      print("error from save_labRequest $e");
      return {"success": false, "message": "Failed to connect to server"};
    }
  }

  //check---
  // Map<String, dynamic> getNotificationBody(
  //   String title,
  //   String message,
  //   String doctorId,
  //   String patientId,
  // ) {
  //   if (doctorId.isNotEmpty) {
  //     return {
  //       "title": title,
  //       "message": message,
  //       "doctor_id": doctorId,
  //     };
  //   } else if (patientId.isNotEmpty) {
  //     return {
  //       "title": title,
  //       "message": message,
  //       "patient_id": patientId,
  //     };
  //   }
  //   throw Exception('Both doctorId and patientId are empty');
  // }
  Map<String, dynamic> buildNotificationBody({
  required String title,
  required String message,
  String? doctorId,
  String? patientId,
}) {
  if (doctorId != null && doctorId.isNotEmpty) {
     print("✅✅✅ i check doctor ");
    return {
      'title': title,
      'message': message,
      'doctor_id': doctorId,
    };
  } else if (patientId != null && patientId.isNotEmpty) {
     print("✅✅✅ i check patient ");
    return {
      'title': title,
      'message': message,
      'patient_id': patientId,
    };
  }
  throw Exception('Either doctorId or patientId must be provided.');
}


  //save_message
  Future<Map<String, dynamic>> saveNotifcation(
      String title, String message, String doctorId, String patientId) async {
    try {
      final body = buildNotificationBody(title: title,message:  message,doctorId:  doctorId,patientId:  patientId);
      print("✅ body---$body");
      final response = await http.post(
        Uri.parse("$url/save_message"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      print("✅✅✅ /save_message");
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          "success": responseBody['success'],
          // "message": responseBody['message']
        };
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Response is not JSON: ${response.body}");
        return {
          "success": false,
          // "message": responseBody['message'] ?? "Unknown error occurred",
        };
      }
    } catch (e) {
      print("error from save_labRequest $e");
      // return {"success": false, "message": "Failed to connect to server"};
      return {"success": false};
    }
  }
}
