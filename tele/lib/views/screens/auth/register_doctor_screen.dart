import 'package:flutter/material.dart';
import 'package:tele/services/username_helper.dart';
import 'package:get/get.dart';
import 'package:tele/Models/hospital_model.dart';
import 'package:tele/Models/specialist_model.dart';
import 'package:tele/controllers/doctor_controller.dart';
import 'package:tele/services/get_api_services.dart';
import 'package:tele/views/screens/auth/login_screen.dart';
import 'package:tele/views/screens/auth/register_screen.dart';
import 'package:tele/views/screens/loading_message_screen.dart';

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({super.key});

  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final DoctorController doctorController = Get.put(DoctorController());
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  final TextEditingController yearsController = TextEditingController();
  final TextEditingController extraDetailController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  // Dropdown values
  String? selectedSpecialityId;
  String? selectedHospitalId;

  late Future<List<SpecialistModel>> _specialistFuture;
  late Future<List<Hospital>> _hospitalFuture;

  @override
  void initState() {
    super.initState();
    _specialistFuture = ApiGetServices().fetchSpecialist();
    _hospitalFuture = ApiGetServices().fetchHospitals();

  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    feeController.dispose();
    yearsController.dispose();
    extraDetailController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 9, 130, 13),
              Color.fromARGB(255, 9, 130, 13).withOpacity(0.8),
              Colors.white,
            ],
            stops: [0.0, 0.2, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      "Doctor Registration",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Registration Form Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 9, 130, 13),
                          ),
                        ),
                        SizedBox(height: 20),
                        buildTextField("Full Name", nameController, Icons.person),
                        buildTextField("Email", emailController, Icons.email, type: TextInputType.emailAddress),
                        buildTextField("Phone", phoneController, Icons.phone, type: TextInputType.phone),
                        buildTextField("Password", passwordController, Icons.lock, isPassword: true),
                        buildTextField("Confirm Password", confirmPasswordController, Icons.lock, isPassword: true),
                        buildTextField("Country", countryController, Icons.public),

                        SizedBox(height: 20),
                        Text(
                          "Professional Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 9, 130, 13),
                          ),
                        ),
                        SizedBox(height: 20),
                        buildTextField("Consultation Fee (\$)", feeController, Icons.attach_money, type: TextInputType.number),
                        buildTextField("Experience (Years)", yearsController, Icons.work, type: TextInputType.number),
                        buildTextField("Additional Details", extraDetailController, Icons.description, maxLines: 3),

                        SizedBox(height: 20),
                        // Speciality Dropdown
                        FutureBuilder<List<SpecialistModel>>(
                          future: _specialistFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: LoadingMessage());
                            }
                            if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            }
                            final specialists = snapshot.data ?? [];
                            return buildDropdownField(
                              "Select Speciality",
                              Icons.local_hospital,
                              specialists.map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              )).toList(),
                              selectedSpecialityId,
                              (value) => setState(() => selectedSpecialityId = value),
                            );
                          },
                        ),

                        SizedBox(height: 16),
                        // Hospital Dropdown
                        FutureBuilder<List<Hospital>>(
                          future: _hospitalFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: LoadingMessage());
                            }
                            if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            }
                            final hospitals = snapshot.data ?? [];
                            return buildDropdownField(
                              "Select Hospital",
                              Icons.local_hospital,
                              hospitals.map((h) => DropdownMenuItem(
                                value: h.id,
                                child: Text(h.name),
                              )).toList(),
                              selectedHospitalId,
                              (value) => setState(() => selectedHospitalId = value),
                            );
                          },
                        ),

                        SizedBox(height: 30),
                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 9, 130, 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (passwordController.text != confirmPasswordController.text) {
                                  Get.snackbar("Error", "Passwords do not match");
                                  return;
                                }

                                // Username is generated from the name with a unique ending
                                String username = generateUsername(nameController.text);

                                final response = await doctorController.registerDoctor(
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  username: username, // Use generated username
                                  password: passwordController.text.trim(),
                                  consultationFee: feeController.text.trim(),
                                  experienceYears: yearsController.text.trim(),
                                  specialityId: selectedSpecialityId!,
                                  hospitalId: selectedHospitalId!,
                                  extraDetail: extraDetailController.text.trim(),
                                  countries: countryController.text.trim(),
                                );

                                if (response["success"] == true) {
                                  Get.snackbar("Success", response["message"]);
                                  Get.offAll(() => LoginScreen());
                                } else {
                                  Get.snackbar("Error", response["message"]);
                                }
                              }
                            },
                            child: Text(
                              "Register as Doctor",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                        // Sign Up as Patient Link
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Want to register as a patient? ",
                              style: TextStyle(fontSize: 13),
                            ),
                            TextButton(
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size(0, 30),
                              ),
                              child: Text(
                                "Sign Up as Patient",
                                style: TextStyle(
                                  fontSize: 13,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color.fromARGB(255, 9, 130, 13)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color.fromARGB(255, 9, 130, 13)),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (value) => value!.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  Widget buildDropdownField(
    String label,
    IconData icon,
    List<DropdownMenuItem<String>> items,
    String? value,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color.fromARGB(255, 9, 130, 13)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color.fromARGB(255, 9, 130, 13)),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: items,
        value: value,
        onChanged: onChanged,
        validator: (value) => value == null ? "Please select $label" : null,
      ),
    );
  }
}