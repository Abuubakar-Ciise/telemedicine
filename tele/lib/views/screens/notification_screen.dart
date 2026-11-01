import 'package:flutter/material.dart';
import 'package:tele/theme/app_theme.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:tele/Models/notifications_model.dart';
import 'package:tele/controllers/notification_controller.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/views/screens/loading_message_screen.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.put(NotificationController());
  String userType = '';
  String userId = '';

  // Track expanded notifications by their index
  final Set<int> _expandedIndexes = {};

  @override
  void initState() {
    super.initState();
    loadUserDataAndFetchNotifications();
  }

  Future<void> loadUserDataAndFetchNotifications() async {
    final data = await StorageService.getUserData();
    userType = data['userType'] ?? '';
    userId = data['userId'] ?? '';

    if (userType == '0') {
      await controller.fetchDoctorNotifications(userId);
    } else if (userType == '1') {
      await controller.fetchPatientNotifications(userId);
    } else {
      print('❌ Invalid user type or missing ID');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(child: LoadingMessage(message: "loading_notifications".tr(),)),
        );
      }

      final hasData = userType == '0'
          ? controller.doctorNotifications.isNotEmpty
          : controller.patientNotifications.isNotEmpty;
          print("maxaa heysaaa ${hasData}");

      return hasData ? _buildNotificationList() : _buildEmptyState();
    });
  }

  Widget _buildNotificationList() {
    final notifications = userType == '0'
        ? controller.doctorNotifications
        : controller.patientNotifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "notifications".tr(),
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemCount: notifications.length,
        itemBuilder: (_, index) {
          final notif = notifications[index];
          if (userType == '0') {
            final doctorNotif = notif as DoctorNotification;
            return _buildTile(
              index: index,
              title: doctorNotif.title,
              message: doctorNotif.message,
              profile: doctorNotif.doctorProfile,
              iconData: _getIconForTitle(doctorNotif.title),
              color: _getColorForTitle(doctorNotif.title),
            );
          } else {
            final patientNotif = notif as PatientNotification;
            return _buildTile(
              index: index,
              title: patientNotif.title,
              message: patientNotif.message,
              profile: patientNotif.patientProfile,
              iconData: _getIconForTitle(patientNotif.title),
              color: _getColorForTitle(patientNotif.title),
            );
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 4,
            shadowColor: Colors.green.shade300,
          ),
          onPressed: () {
            // TODO: Add clear all notifications logic here
          },
          icon: const Icon(Icons.clear_all, color: Colors.white),
          label: Text(
            "clear_all_notifications".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required int index,
    required String title,
    required String message,
    required String profile,
    required IconData iconData,
    required Color color,
  }) {
    final imageUrl =
        profile.startsWith("http") ? profile : "${Config.baseUrl}/$profile";

    final isExpanded = _expandedIndexes.contains(index);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(imageUrl),
          backgroundColor: color.withOpacity(0.15),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.black87,
          ),
        ),
        subtitle: GestureDetector(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedIndexes.remove(index);
              } else {
                _expandedIndexes.add(index);
              }
            });
          },
          child: Text(
            message,
            maxLines: isExpanded ? null : 2,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
        trailing: Icon(iconData, color: color, size: 30),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "no_notifications_yet".tr(),
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    final t = title.toLowerCase();

    if (t.contains("lab request") || t.contains("lab test") || t.contains("lab result")) return Icons.biotech;
    if (t.contains("appointment") || t.contains("schedule") || t.contains("booking")) return Icons.calendar_today;
    if (t.contains("prescription") || t.contains("medication")) return Icons.receipt_long;
    if (t.contains("video call") || t.contains("video consultation")) return Icons.videocam;
    if (t.contains("message") || t.contains("chat") || t.contains("conversation")) return Icons.message;
    if (t.contains("payment") || t.contains("billing") || t.contains("invoice")) return Icons.payment;
    if (t.contains("report") || t.contains("summary")) return Icons.assignment;
    if (t.contains("profile") || t.contains("account")) return Icons.person;
    if (t.contains("alert") || t.contains("emergency") || t.contains("critical")) return Icons.warning_amber_rounded;
    if (t.contains("reminder") || t.contains("notification")) return Icons.alarm;
    if (t.contains("new patient") || t.contains("register") || t.contains("signup")) return Icons.how_to_reg;
    if (t.contains("test result")) return Icons.analytics;
    if (t.contains("follow-up") || t.contains("follow up")) return Icons.follow_the_signs;
    if (t.contains("consultation")) return Icons.local_hospital;
    if (t.contains("cancelled") || t.contains("canceled")) return Icons.cancel;
    if (t.contains("reschedule")) return Icons.schedule;
    if (t.contains("urgent")) return Icons.priority_high;
    if (t.contains("feedback") || t.contains("review")) return Icons.feedback;
    if (t.contains("covid") || t.contains("corona")) return Icons.health_and_safety;
    if (t.contains("vaccination") || t.contains("vaccine")) return Icons.medical_services;

    return Icons.notifications_none;
  }
  Color _getColorForTitle(String title) {
    final t = title.toLowerCase();

    if (t.contains("lab request") || t.contains("lab test") || t.contains("lab result")) return Colors.purple;
    if (t.contains("appointment") || t.contains("schedule") || t.contains("booking")) return Colors.blue;
    if (t.contains("prescription") || t.contains("medication")) return AppColors.brand;
    if (t.contains("video call") || t.contains("video consultation")) return Colors.deepOrange;
    if (t.contains("message") || t.contains("chat") || t.contains("conversation")) return Colors.green;
    if (t.contains("payment") || t.contains("billing") || t.contains("invoice")) return Colors.brown;
    if (t.contains("report") || t.contains("summary")) return Colors.indigo;
    if (t.contains("profile") || t.contains("account")) return Colors.cyan;
    if (t.contains("alert") || t.contains("emergency") || t.contains("critical")) return Colors.redAccent;
    if (t.contains("reminder") || t.contains("notification")) return Colors.amber;
    if (t.contains("new patient") || t.contains("register") || t.contains("signup")) return Colors.lightGreen;
    if (t.contains("test result")) return Colors.deepPurple;
    if (t.contains("follow-up") || t.contains("follow up")) return Colors.blueGrey;
    if (t.contains("consultation")) return Colors.tealAccent.shade700;
    if (t.contains("cancelled") || t.contains("canceled")) return Colors.grey;
    if (t.contains("reschedule")) return Colors.orange;
    if (t.contains("urgent")) return Colors.red;
    if (t.contains("feedback") || t.contains("review")) return Colors.pink;
    if (t.contains("covid") || t.contains("corona")) return Colors.lightBlueAccent;
    if (t.contains("vaccination") || t.contains("vaccine")) return Colors.greenAccent;

    return Colors.grey;
  }
}
