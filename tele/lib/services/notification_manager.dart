import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static const String _activeNotificationsKey = 'active_notifications';
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Store active notification data
  static Future<void> storeActiveNotification(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final activeNotifications = await getActiveNotifications();
    activeNotifications[id.toString()] = data;
    await prefs.setString(_activeNotificationsKey, jsonEncode(activeNotifications));
  }

  // Get all active notifications
  static Future<Map<String, dynamic>> getActiveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString(_activeNotificationsKey) ?? '{}';
    return jsonDecode(notificationsJson) as Map<String, dynamic>;
  }

  // Remove notification from active list
  static Future<void> removeActiveNotification(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final activeNotifications = await getActiveNotifications();
    activeNotifications.remove(id.toString());
    await prefs.setString(_activeNotificationsKey, jsonEncode(activeNotifications));
  }

  // Get notification data by ID
  static Future<Map<String, dynamic>?> getNotificationData(int id) async {
    final activeNotifications = await getActiveNotifications();
    final data = activeNotifications[id.toString()];
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // Clear all active notifications
  static Future<void> clearAllActiveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeNotificationsKey);
    await _plugin.cancelAll();
  }

  // Get pending notifications from system
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
    await removeActiveNotification(id);
  }
}