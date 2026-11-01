import 'package:flutter/material.dart';
import 'package:tele/views/screens/components/app_bottom_nav.dart';
import 'package:tele/views/screens/DoctorScreens/doctor_home_screen.dart';
import 'package:tele/views/screens/DoctorScreens/doctor_transection_history_screen.dart';
import 'package:tele/views/screens/patient/contact_us_screen.dart';
import 'package:tele/views/screens/notification_screen.dart';

class DoctorMainScreen extends StatefulWidget {
  const DoctorMainScreen({super.key});

  @override
  State<DoctorMainScreen> createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen> {
  int _selectedItem = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

  final List<Widget> screens = [
    DoctorHomeScreen(),
    NotificationScreen(),
    DoctorTransectionHistoryScreen(),
    ContactUsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedItem],
      bottomNavigationBar: AppBottomNav(currentIndex: _selectedItem, onTap: _onItemTapped),
    );
  }

}
