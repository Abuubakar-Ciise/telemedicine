import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:tele/Models/hospital_model.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/views/screens/components/config.dart';

class AuthServices {

  static String get url => Config.baseUrl;

  // register Patient
  static Future<Map<String, dynamic>> registerPatient(
      String name,
      String email,
      String address,
      String gender,
      int age,
      String phone,
      String username,
      String password) async {
    try {
      final response = await http.post(Uri.parse('$url/register_Patient'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "name": name,
            "email": email,
            "address": address,
            "gender": gender,
            "age": age,
            "phone": phone,
            'user_name': username,
            "PassWord": password
          }));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          "success": responseBody["success"],
          "message": responseBody["message"],
          "record": responseBody["record"] ?? {},
        };
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return {
          "success": false,
          "message": responseBody['message'] ?? "Unknown error occurred",
        };
      }
    } catch (e) {
      print("Registration failed: $e");
      return {"success": false, "message": "Cannot reach the server at ${Config.baseUrl}. Check Server settings on the login screen."};
    }
  }

  // login_DoctorAndPatient
  static Future<Map<String, dynamic>> loginDoctorAndPatient(
    String email,
    String password,
    String token
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$url/login_DoctorAndPatient"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "PassWord": password,'token':token}),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      // If the API explicitly returns success = false, handle it
      if (responseBody['success'] == false) {
        return {
          "success": false,
          "message": responseBody['message'] ?? "Invalid credentials",
        };
      }
      // If success = true, proceed
      if (response.statusCode == 200 && responseBody['success'] == true) {
        final record = responseBody['record'];
        print("this is the type  ${record['type']}");

        // generate token
        final jwt = JWT({
          "id": record['_id'],
          'email':record['email'],
          'type': record['type'],
          'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + (7 * 24 * 60 * 60), // 7 days expiry
        });
        String token = jwt.sign(SecretKey('my_secret_key'));

        await StorageService.saveUserData(
          token , record['_id'] , record['name'] ?? '',record['type'] ?? 0,
          record['email'] ?? '',record['address'] ?? '',record['gender'] ?? '',record['age'] ?? 20,record['phone'] ?? '',record['picture'] ?? '',record['user_name'] ?? ''
          );
        print("current user etails  $token ----- ${record['_id']} ---- ${record['name']}--- ${record['type']} --- ${record['email']} -- ${record['address']} -- ${record['gender']} --${record['age']} -- ${record['phone']} --${record['picture']} --- ${record['user_name']}");
        return {
          "success": true,
          "message": responseBody['message'] ?? "Login successful",
          "record": record,
          "type": record?['type'] ?? "unknown"
        };
      } else {
        // Handle unexpected response
        return {
          "success": false,
          "message": responseBody['message'] ?? "Unexpected error",
        };
      }
    } catch (e) {
      print("Login failed: $e");
      return {"success": false, "message": "Cannot reach the server at ${Config.baseUrl}. Check Server settings on the login screen."};
    }
  }

  static Future<List<Hospital>> fetchHospitals() async {
    try {
      final response = await http.post(Uri.parse('$url/getAll_Hospitals'));
      print("Fetching data from: $url/getAll_Hospitals");

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

   Future<Map<String, dynamic>> registerDoctor({
    required String name,
    required String email,
    required String phone,
    required String username,
    required String password,
    required String consultationFee,
    required String experienceYears,
    required String specialityId,
    required String hospitalId,
    required String extraDetail,
    required String countries,
  }) async {
    try {
      final uri = Uri.parse("$url/register_Doctor");

      var request = http.MultipartRequest("POST", uri);

      // body params
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['user_name'] = username;
      request.fields['PassWord'] = password;
      request.fields['consultation_fee'] = consultationFee;
      request.fields['experience_years'] = experienceYears;
      request.fields['speciality_id'] = specialityId;
      request.fields['hospital_id'] = hospitalId;
      request.fields['extra_detail'] = extraDetail;

      // if you want to upload picture, use:
      // request.files.add(await http.MultipartFile.fromPath("picture", imagePath));
      request.fields['countries'] = countries;  // Added countries field

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }


   // Forget Password - Send OTP
  static Future<Map<String, dynamic>> forgetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$url/forget_Password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final body = jsonDecode(response.body);
      return {
        "success": body['success'] ?? false,
        "message": body['message'] ?? "Something went wrong",
      };
    } catch (e) {
      print("Forget Password Error: $e");
      return {"success": false, "message": "Server connection failed"};
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse("$url/VerifyOtp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      final body = jsonDecode(response.body);
      return {
        "success": body['success'] ?? false,
        "message": body['message'] ?? "Something went wrong",
        "userId": body['userId'],
        "userType": body['userType'],
      };
    } catch (e) {
      print("Verify OTP Error: $e");
      return {"success": false, "message": "Server connection failed"};
    }
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword(
      String email, String newPassword, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse("$url/resetPassword"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword
        }),
      );

      final body = jsonDecode(response.body);
      return {
        "success": body['success'] ?? false,
        "message": body['message'] ?? "Something went wrong",
        "userId": body['userId'],
        "userType": body['userType'],
      };
    } catch (e) {
      print("Reset Password Error: $e");
      return {"success": false, "message": "Server connection failed"};
    }
  }

}
