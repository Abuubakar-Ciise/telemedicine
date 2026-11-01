import 'package:flutter/material.dart';
import 'package:tele/services/username_helper.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/instance_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tele/controllers/auth_controller.dart';
import 'package:tele/views/screens/auth/login_screen.dart';
import 'package:tele/views/screens/auth/register_doctor_screen.dart';
import 'package:tele/views/screens/loading_message_screen.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  final authController = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Green Background
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 9, 130, 13),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "dont_have_account".tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
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
                ],
              ),

              const SizedBox(height: 30),

              // White Container for Form
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
                          // Full Name
                          buildTextField(
                              Icons.person, "full_name".tr(), _fullNameController),
                          buildPhoneField(_phoneController),
                          buildEmailField(_emailController),
                          buildTextField(Icons.location_on_outlined, "address".tr(),
                              _addressController),

                          // Gender Dropdown
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person,
                                    color: Colors.black),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              value: _genderController.text.isEmpty
                                  ? null
                                  : _genderController.text,
                              hint: Text('select_gender'.tr()),
                              dropdownColor: Colors.white,
                              items: ['male'.tr(), 'female'.tr()].map((String gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(gender),
                                );
                              }).toList(),
                              onChanged: (value) {
                                _genderController.text = value!;
                              },
                              validator: (value) => value == null
                                  ? "please_select_gender".tr()
                                  : null,
                            ),
                          ),
                          // Other Fields
                          buildAgeField(Icons.cake, "age".tr(), _ageController),

                          // buildPasswordField("Password", _passwordController),
                          // buildConfirmPasswordField("Confirm Password", _confirmPasswordController),
                          PasswordField(
                              hint: "password".tr(),
                              controller: _passwordController),
                          ConfirmPasswordField(
                              hint: "confirm_password".tr(),
                              controller: _confirmPasswordController,
                              passwordController: _passwordController),

                          const SizedBox(height: 20),

                          // Register Button
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      int age =
                                          int.tryParse(_ageController.text) ??
                                              0;
                                      String fullPhoneNumber =
                                          "+252${_phoneController.text.trim()}";
                                      if (_formKey.currentState!.validate()) {
                                        await authController.registerPatient(
                                          _fullNameController.text.trim(),
                                          _emailController.text.trim(),
                                          _addressController.text.trim(),
                                          _genderController.text.trim(),
                                          age,
                                          fullPhoneNumber,
                                          generateUsername(_fullNameController.text),
                                          _passwordController.text.trim(),
                                        );
                                      }
                                    },
                                    child: Text(
                                      "sign_up".tr(),
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 15),

                          // Login Link
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("already_have_account".tr()),
                              TextButton(
                                onPressed: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    Get.offAll(() => LoginScreen());
                                  }
                                },
                                child: Text(
                                  "sign_in".tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 9, 130, 13),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Sign Up Us Doctor Link
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Sign Up As Doctor".tr()),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterDoctorScreen()),
                                  );
                                },
                                child: Text(
                                  "sign_up".tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 9, 130, 13),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  // Text Field with Validation
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
        validator: (value) => value!.isEmpty ? "${"please_enter".tr()} $hint" : null,
      ),
    );
  }

  // Text Field with Validation
  Widget buildAgeField(
      IconData icon, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
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
        validator: (value) => value!.isEmpty ? "${"please_enter".tr()} $hint" : null,
      ),
    );
  }

  // Email Field with Validation
  Widget buildEmailField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          // prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 9, 130, 13)),
          prefixIcon: const Icon(Icons.email, color: Colors.black),
          hintText: "email".tr(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return "please_enter_email".tr();
          } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA0-9.-]+\.[a-zA-Z]{2,}$")
              .hasMatch(value)) {
            return "enter_valid_email".tr();
          }
          return null;
        },
      ),
    );
  }

  Widget buildPhoneField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          // Combine icon + prefix in one go
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.phone, size: 20, color: Colors.black87),
                SizedBox(width: 4),
                Text(
                  '+252',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          hintText: "enter_phone_number".tr(),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "please_enter_phone".tr();
          } else if (value.length < 9 || value.length > 12) {
            return "enter_valid_phone".tr();
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

  const PasswordField({Key? key, required this.hint, required this.controller})
      : super(key: key);

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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          prefixIcon: const Icon(Icons.lock, color: Colors.black),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          hintText: widget.hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "please_enter_password".tr();
          } else if (value.length < 6) {
            return "password_must_be_6_characters".tr();
          }
          return null;
        },
      ),
    );
  }
}

class ConfirmPasswordField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextEditingController passwordController;

  const ConfirmPasswordField({
    Key? key,
    required this.hint,
    required this.controller,
    required this.passwordController,
  }) : super(key: key);

  @override
  _ConfirmPasswordFieldState createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          prefixIcon: const Icon(Icons.lock, color: Colors.black),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          hintText: widget.hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "please_confirm_password".tr();
          } else if (value != widget.passwordController.text) {
            return "passwords_do_not_match".tr();
          }
          return null;
        },
      ),
    );
  }
}
