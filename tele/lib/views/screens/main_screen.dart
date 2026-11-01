import 'package:flutter/material.dart';
import 'package:tele/views/screens/components/app_bottom_nav.dart';
import 'package:tele/views/screens/patient/TransactionHistoryScreen.dart';
import 'package:tele/views/screens/patient/contact_us_screen.dart';
import 'package:tele/views/screens/home_screen.dart';
import 'package:tele/views/screens/notification_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedItem = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

  final List<Widget> screens = [
    HomeScreen(),
    // Center(child: Text("Notification Screen")),
    //  ChatsListScreenAppointment(),
    NotificationScreen(),
    TransactionHistoryScreen(),
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