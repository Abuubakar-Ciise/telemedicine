import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:tele/controllers/auth_controller.dart';
import 'package:tele/views/screens/auth/forget_password.dart';
import 'package:tele/views/screens/auth/register_screen.dart';
import 'package:tele/views/screens/components/server_settings_dialog.dart';
import 'package:tele/views/screens/loading_message_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _firebaseMessaging = FirebaseMessaging.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 130, 13),
      body: Stack(
        children: [
          // Background
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 9, 130, 13),
            ),
          ),

          // Content
          Column(
            children: [
              const SizedBox(height: 100), // Push content down a bit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "already_have_account".tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // White Container for the Form
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildTextField(Icons.person, 'email_or_phone'.tr(),
                              _emailController),
                          const SizedBox(height: 15),
                          // buildPasswordField('Password', _passwordController),
                          PasswordField(
                              hint: "password".tr(),
                              controller: _passwordController),
                          const SizedBox(height: 20),
                          Obx(
                            () => authController.isLoading.value
                                ? LoadingMessage()
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 9, 130, 13),
                                      // Full-width button that fits any screen size
                                      minimumSize: const Size(double.infinity, 52),
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        // Push token is optional: log in even if Firebase is unavailable
                                        String token = '';
                                        try {
                                          token = await _firebaseMessaging
                                                  .getToken()
                                                  .timeout(const Duration(seconds: 8)) ??
                                              '';
                                        } catch (e) {
                                          debugPrint('⚠️ No FCM token at login: $e');
                                        }
                                        await authController
                                            .loginDoctorAndPatient(
                                                _emailController.text.trim(),
                                                _passwordController.text
                                                    .trim(),token);
                                        
                                      }
                                    },
                                    child: Text(
                                      "sign_in".tr(),
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Get.to(() => ForgetPasswordScreen());
                            },
                            child: Text(
                              "forgot_password".tr(),
                              style: TextStyle(
                                  color: Color.fromARGB(255, 9, 130, 13)),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text("dont_have_account".tr()),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterScreen()),
                              );
                            },
                            child: Text(
                              "sign_up".tr(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 9, 130, 13)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 9, 130, 13),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.help, color: Colors.white),
                            label: Text(
                              "help".tr(),
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Server settings (change the API address without rebuilding)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              tooltip: 'Server settings',
              icon: const Icon(Icons.settings_ethernet, color: Colors.white),
              onPressed: () => showServerSettingsDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build text fields with validation
  Widget buildTextField(
      IconData icon, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          // prefixIcon: Icon(icon, color: const Color.fromARGB(255, 9, 130, 13)),
          prefixIcon: Icon(icon, color: Colors.black),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your email or username";
          }
          return null;
        },
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;

  const PasswordField({super.key, required this.hint, required this.controller});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.black),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText; // Toggle password visibility
              });
            },
          ),
          hintText: widget.hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your password";
          } else if (value.length < 6) {
            return "Password must be at least 6 characters";
          }
          return null;
        },
      ),
    );
  }
}
