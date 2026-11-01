

import 'package:get/get.dart';
import 'package:tele/PrescriptionScreen.dart';
import 'package:tele/views/screens/DoctorScreens/conseltaion_screen.dart';
import 'package:tele/views/screens/DoctorScreens/doctor_home_screen.dart';
import 'package:tele/views/screens/DoctorScreens/doctor_main_screen.dart';
import 'package:tele/views/screens/Hospitals/HospitalListScreen.dart';
import 'package:tele/views/screens/auth/login_screen.dart';
import 'package:tele/views/screens/auth/register_screen.dart';
import 'package:tele/views/screens/notification_screen.dart';
import 'package:tele/views/screens/patient/Video_Consultation_Screen.dart';
import 'package:tele/views/screens/main_screen.dart';
import 'package:tele/views/screens/patient/chats_list_screen_appointment.dart';
import 'package:tele/views/screens/patient/shift_appointment_screen.dart';
import 'package:tele/views/testcallscreen.dart';

class AppRoutes{
  static final routes = [
    GetPage(name: '/login', page: () => LoginScreen()),
    GetPage(name: '/register', page: () => RegisterScreen()),
    GetPage(name: '/mainscreen', page: () => MainScreen()),
    GetPage(name: '/doctormainscreen', page: () => DoctorMainScreen()),
    GetPage(name: '/doctorhomescreen', page: () => DoctorHomeScreen()),
    GetPage(name: '/HospitalList', page: () => HospitalListScreen()),
    GetPage(name: '/doctorList', page: () => VideoConsultationScreen()),
    GetPage(name: '/shitsScreen', page: () => ShiftAppointmentScreen(doctor: Get.arguments,)),
    GetPage(name: '/testcall', page: () => Testcallscreen()),
     GetPage(name: '/mytreatment', page: () => ChatsListScreenAppointment()),
     GetPage(name: '/consultation', page: () => ConseltaionScreen()),
     GetPage(name: '/notificationscreen', page: () => NotificationScreen()),
    GetPage(name: '/prescriptionscreen', page: () => PrescriptionScreen(patientId: '', doctorId: '', appointmentId: '',)),
    // GetPage(name: '/doctorprescriptionscreen', page: () => DoctorPrescriptionScreen()),
  ];
}