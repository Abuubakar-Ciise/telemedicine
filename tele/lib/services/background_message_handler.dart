// background_message_handler.dart

import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:uuid/uuid.dart';
import 'package:tele/services/background_call_handler.dart';
import 'package:tele/services/call_session.dart';
import 'package:tele/services/firebase_api.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/views/screens/CallPage/call_helpers.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await Config.ensureLoaded();
  try {
    print('🔔 Background message received: ${message.messageId}');
    print('🔔 Background message data: ${message.data}');

    final data = message.data;

    if (data.isEmpty || message.messageId == null || message.messageId == 'null') {
      print('🔔 Ignoring empty/invalid message from ZPNs');
      return;
    }

    if (data['type'] == null || data['type'].toString().isEmpty) {
      print('🔔 Ignoring message without valid type');
      return;
    }

    if (data['type'] == 'call_invitation') {
      await _showBackgroundCallKitDirect(data);
    } else if (data['type'] == 'call_end') {
      await _endBackgroundCallDirect();
    } else {
      await _showBackgroundNotification(message);
    }
  } catch (e) {
    print('❌ Error in background message handler: $e');
    await BackgroundCallHandler.handleBackgroundCall(message);
  }
}

@pragma('vm:entry-point')
Future<void> _showBackgroundCallKitDirect(Map<String, dynamic> data) async {
  try {
    final uuid = const Uuid().v4();
    final params = buildIncomingCallParams(
      id: uuid,
      callerName: data['callerName'] ?? '',
      picture: data['picture'] ?? '',
      callerPhone: data['callerPhone'] ?? '',
      callType: data['callType'] ?? '0',
      extra: {
        'roomId': data['roomId'] ?? '',
        'callerToken': data['callerToken'] ?? '',
        'calleeToken': data['calleeToken'] ?? '',
        'callType': data['callType'] ?? '0',
        'callerType': data['callerType'] ?? 'doctor',
        'doctor_id': data['doctor_id'] ?? '',
        'patient_id': data['patient_id'] ?? '',
        'isIncoming': 'true',
        'isCaller': 'false',
      },
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
    print('🔔 Background CallKit shown successfully with ID: $uuid');

    // The app may be closed: report Decline / time-out from here, so the
    // caller's screen closes (it checks the call status every 2 s).
    final roomId = (data['roomId'] ?? '').toString();
    StreamSubscription? sub;
    sub = FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null || event.body['id'] != uuid) return;
      if (event.event == Event.actionCallDecline) {
        CallSession.update(roomId, 'declined');
        final callerType = (data['callerType'] ?? 'doctor').toString();
        FirebaseApis().sendCallEndTo(
          toType: callerType,
          toId: (callerType == 'doctor' ? data['doctor_id'] : data['patient_id'] ?? '').toString(),
          doctorId: (data['doctor_id'] ?? '').toString(),
          patientId: (data['patient_id'] ?? '').toString(),
          roomId: roomId,
        );
        sub?.cancel();
      } else if (event.event == Event.actionCallTimeout) {
        CallSession.update(roomId, 'missed');
        sub?.cancel();
      } else if (event.event == Event.actionCallAccept || event.event == Event.actionCallEnded) {
        sub?.cancel();
      }
    });
    Future.delayed(const Duration(seconds: 60), () => sub?.cancel());
  } catch (e) {
    print('❌ Error showing background CallKit: $e');
  }
}

@pragma('vm:entry-point')
Future<void> _endBackgroundCallDirect() async {
  try {
    await FlutterCallkitIncoming.endAllCalls();
    print('🔔 Background call ended successfully');
  } catch (e) {
    print('❌ Error ending background call: $e');
  }
}

@pragma('vm:entry-point')
Future<void> _showBackgroundNotification(RemoteMessage message) async {
  try {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
      'default_channel',
      'Default',
      description: 'General notifications',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'General notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final title = message.data['title'] ??
        message.notification?.title ??
        'New Notification';
    final body = message.data['body'] ??
        message.notification?.body ??
        'You have a new notification';

    await flutterLocalNotificationsPlugin.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );

    print('🔔 Background notification shown successfully');
  } catch (e) {
    print('❌ Error showing background notification: $e');
  }
}
