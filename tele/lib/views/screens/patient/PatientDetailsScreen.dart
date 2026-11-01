import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tele/Models/doctors_list_nodel.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/views/screens/patient/confirmation_screen.dart';
import 'package:toastification/toastification.dart';

class PatientDetailsScreen extends StatefulWidget {
  final DoctorList doctor;
  final String selectedDate;
  final String? selectedTime;
  final String shiftId;
  final Map<String, dynamic>? selectedPackage;

  const PatientDetailsScreen({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedTime,
    required this.shiftId,
    this.selectedPackage,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController problemController = TextEditingController();
  String m = '';
  int selectedGender = 0;
  String patientId = '';

  Future<void> loadUserData() async {
    Map<String,String?> userData =await StorageService.getUserData();
    String gender = userData['gender'] ?? '';
    String  mmmm = userData['phone'] ?? '';
    // String fullName = userData['']
    setState(() {
      nameController.text = userData['username'] ?? '';
      phoneController.text = formatMerchantPhone(userData['phone'] ?? '');
      ageController.text = userData['age'] ?? '';
      patientId = userData['userId'] ?? '';
      if(gender == 'Male'){
        selectedGender = 0;
      }else if(gender == 'Female'){
        selectedGender = 1;
      }
      // selectedGender 
    });
  }
  String formatMerchantPhone(String phone) {
  // Remove the country code if it exists
  if (phone.startsWith('+252')) {
    return phone.substring(4); // Remove "+252"
  } else if (phone.startsWith('252')) {
    return phone.substring(3); // Remove "252"
  }
  return phone; // Already local
}


  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
        title: Text(
          "patient_details".tr(),
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name Input
            Text("full_name".tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              readOnly: true,
              controller: nameController,
              decoration: InputDecoration(
                hintText: "enter_your_name".tr(),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 16),
            Text("phone_number".tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            // Text("${DateFormat('MMM d, yyyy').format(widget.selectedDay)}"),
            TextField(
               keyboardType: TextInputType.number,
              controller: phoneController,
              decoration: InputDecoration(
                hintText: "enter_your_number".tr(),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 16),

            // Age Input
            Text("age".tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              readOnly: true,
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "enter_your_age".tr(),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 16),

            // Gender Selection
            Text("gender".tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            
            ToggleButtons(
              
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: Color.fromARGB(255, 9, 130, 13),
              color: Colors.black,
              isSelected: [selectedGender == 0, selectedGender == 1],
              onPressed: (_) {},
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("male".tr())),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("female".tr())),
              ],
            ),

            const SizedBox(height: 16),

            // Problem Input
            Text("write_your_problem".tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: problemController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "write_your_problem".tr(),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 24),

            // Next Button
            ElevatedButton(
              onPressed: () {
                if (problemController.text == null || problemController.text.isEmpty) {
                toastification.show(
                  type: ToastificationType.error,
                  style: ToastificationStyle.flat,
                  title: Text('error'.tr()),
                  description: Text('please_tell_us_your_problem'.tr()),
                  autoCloseDuration: const Duration(seconds: 3),
                  alignment: Alignment.topRight,
                  showProgressBar: true,
                );
              }else {
                // Create a map of patient data
                final patientData = {
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'age': ageController.text,
                  'gender': selectedGender == 0 ? 'Male' : 'Female',
                  'problem': problemController.text,
                };

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmationScreen(
                      patientData: patientData,
                      doctor: widget.doctor,
                      selectedDay: widget.selectedDate,
                      selectedTime: widget.selectedTime,
                      selectedPackage: widget.selectedPackage,
                      selectedDate:widget.selectedDate,
                      patientId: patientId,
                      shifId:widget.shiftId,
                    ),
                  ),
                );
              }
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 9, 130, 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text("next".tr(),
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
