// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:get/get.dart';
// import 'package:tele/services/notification_service.dart';
// import 'package:tele/services/notification_debug_helper.dart';
// import 'package:tele/services/notification_manager.dart';

// class FirebaseNotificationHandler {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   final GlobalKey<NavigatorState> navigatorKey;
//   bool _isAppInForeground = true; // Track app state

//   FirebaseNotificationHandler(this.navigatorKey);

//   Future<void> initNotification() async {
//     // iOS permission
//     if (Platform.isIOS) {
//       await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//     }

//     // Initialize local notifications
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: androidSettings);
//     await _localNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         await NotificationDebugHelper.logNotificationEvent(
//           'Local notification tapped',
//           {'payload': response.payload, 'actionId': response.actionId}
//         );
//         if (response.payload != null && response.payload!.isNotEmpty) {
//           try {
//             final payloadData = jsonDecode(response.payload!) as Map<String, dynamic>;
//             Map<String, dynamic>? notificationData;
//             if (payloadData.containsKey('notificationId')) {
//               final notificationId = payloadData['notificationId'] as int;
//               notificationData = await NotificationManager.getNotificationData(notificationId);
//               await NotificationManager.removeActiveNotification(notificationId);
//             }
//             final dataToUse = notificationData ?? payloadData;
//             await NotificationDebugHelper.logNotificationEvent(
//               'Using notification data',
//               {'source': notificationData != null ? 'manager' : 'payload', 'data': dataToUse}
//             );
//             await handleNotificationNavigation(dataToUse);
//           } catch (e) {
//             print("Error parsing notification payload: $e");
//             await handleNotificationNavigation({'type': response.payload});
//           }
//         }
//       },
//     );

//     // Foreground message listener: only show local notification if app is in foreground
//     FirebaseMessaging.onMessage.listen((message) async {
//       await NotificationDebugHelper.logNotificationEvent(
//         'Foreground message received',
//         message.data
//       );
      
//       // Debug: Check if message has notification field (required for background taps)
//       if (message.notification != null) {
//         print("🔔 DEBUG: Message has notification field - background taps will work");
//         print("🔔 DEBUG: Notification title: ${message.notification?.title}");
//         print("🔔 DEBUG: Notification body: ${message.notification?.body}");
//         print("🔔 DEBUG: Notification android: ${message.notification?.android}");
//         print("🔔 DEBUG: Notification apple: ${message.notification?.apple}");
//       } else {
//         print("⚠️ WARNING: Message has NO notification field - background taps will NOT work");
//         print("⚠️ WARNING: Only data field present: ${message.data}");
//       }
      
//       // Debug: Check message structure
//       print("🔔 DEBUG: Full message data: ${message.data}");
//       print("🔔 DEBUG: Message ID: ${message.messageId}");
//       print("🔔 DEBUG: Message sent time: ${message.sentTime}");
//       print("🔔 DEBUG: Message ttl: ${message.ttl}");
//       print("🔔 DEBUG: Message collapse key: ${message.collapseKey}");
      
//       // ONLY show local notification if app is in foreground
//       if (_isAppInForeground) {
//         print("🔔 DEBUG: App is in foreground - showing local notification");
//         _showLocalNotification(message);
//       } else {
//         print("🔔 DEBUG: App is in background - skipping local notification (system will show)");
//       }
//     });

//     // Background: handle notification tap
//     FirebaseMessaging.onMessageOpenedApp.listen((message) async {
//       print("🔔 DEBUG: onMessageOpenedApp triggered - background notification tapped");
//       await NotificationDebugHelper.logNotificationEvent(
//         'App opened from background via notification',
//         message.data
//       );
//       await handleNotificationNavigation(message.data);
//     });

//     // Test: Check if system notifications are working
//     print("🔔 DEBUG: Setting up notification handlers...");
//     print("🔔 DEBUG: onMessageOpenedApp listener registered");
//     print("🔔 DEBUG: getInitialMessage check completed");
//     print("🔔 DEBUG: Testing notification channel setup...");
    
//     // Test notification channel
//     final androidPlugin = _localNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//     if (androidPlugin != null) {
//       final channels = await androidPlugin.getNotificationChannels();
//       print("🔔 DEBUG: Available notification channels: ${channels?.length ?? 0}");
//       for (final channel in channels ?? []) {
//         print("🔔 DEBUG: Channel: ${channel.id} - ${channel.name} - ${channel.importance}");
//       }
//     }

//     // Terminated: handle notification tap ONCE at app start
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       print("🔔 DEBUG: getInitialMessage found - terminated notification tapped");
//       await NotificationDebugHelper.logNotificationEvent(
//         'App launched by notification',
//         initialMessage.data
//       );
//       await handleNotificationNavigation(initialMessage.data);
//     } else {
//       print("🔔 DEBUG: getInitialMessage returned null - no terminated notification");
//     }
//   }

//   // Method to update app state
//   void setAppState(bool isInForeground) {
//     _isAppInForeground = isInForeground;
//     print("🔔 DEBUG: App state changed - Foreground: $_isAppInForeground");
//   }

//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     // Create a persistent notification ID based on message type and timestamp
//     final notificationId = message.data['type'].hashCode + DateTime.now().millisecondsSinceEpoch ~/ 10000;
    
//     // Store notification data in manager for persistent access
//     await NotificationManager.storeActiveNotification(notificationId, message.data);
    
//     final androidDetails = AndroidNotificationDetails(
//       'default_channel',
//       'Default',
//       importance: Importance.max,
//       priority: Priority.high,
//       channelShowBadge: true,
//       autoCancel: false, // Don't auto-cancel the notification
//       ongoing: false, // Allow user to dismiss
//       enableVibration: true,
//       playSound: true,
//       timeoutAfter: null, // Don't timeout
//       ticker: 'New notification received',
//       showWhen: true,
//       when: DateTime.now().millisecondsSinceEpoch,
//       usesChronometer: false,
//       fullScreenIntent: false,
//       category: AndroidNotificationCategory.message,
//       visibility: NotificationVisibility.public,
//       actions: <AndroidNotificationAction>[
//         AndroidNotificationAction(
//           'open_action',
//           'Open',
//           showsUserInterface: true,
//         ),
//       ],
//     );
    
//     final platformDetails = NotificationDetails(android: androidDetails);
    
//     // Store complete notification data as JSON payload with ID for retrieval
//     final payload = jsonEncode({
//       'notificationId': notificationId,
//       ...message.data,
//     });
    
//     print("Showing local notification with ID: $notificationId");
//     print("Payload: $payload");
    
//     await _localNotificationsPlugin.show(
//       notificationId,
//       message.notification?.title ?? 'New Notification',
//       message.notification?.body ?? 'Tap to open',
//       platformDetails,
//       payload: payload,
//     );
    
//     // Also store the notification data as backup
//     await NotificationService.storePendingNotification(message.data);
//   }

//   Future<void> handleNotificationNavigation(Map<String, dynamic> data) async {
//     await NotificationDebugHelper.logNotificationEvent(
//       'Handling notification navigation', 
//       data
//     );
    
//     // Wait for app to be fully initialized
//     await Future.delayed(Duration(milliseconds: 500));
    
//     final context = navigatorKey.currentContext;
//     if (context == null) {
//       print("Context unavailable - storing notification for later");
//       await NotificationService.storePendingNotification(data);
//       return;
//     }

//     final prefs = await SharedPreferences.getInstance();
//     final userType = prefs.getString('userType'); // '0' for doctor, '1' for patient

//     if (userType == null) {
//       print("User type not found in SharedPreferences");
//       await NotificationDebugHelper.logNotificationEvent(
//         'User type not found - storing for later', 
//         data
//       );
//       await NotificationService.storePendingNotification(data);
//       return;
//     }

//     final type = data['type']?.toString();
//     await NotificationDebugHelper.logNotificationEvent(
//       'Ready to navigate', 
//       {'type': type, 'userType': userType}
//     );
    
//     _redirectBasedOnUserType(context, type, userType);
//   }

//   void _redirectBasedOnUserType(
//     BuildContext context,
//     String? type,
//     String userType,
//   ) {
//     String route;
//     bool shouldPreserveStack = false; // Flag to determine navigation strategy
    
//     switch (type) {
//       case 'appointment_booking':
//         route = userType == '0' ? '/consultation' : '/mainscreen';
//         shouldPreserveStack = false; // Go to home, clear stack
//         break;
//       case 'appointment_completed':
//         route = userType == '0' ? '/doctormainscreen' : '/mytreatment';
//         shouldPreserveStack = false; // Go to home, clear stack
//         break;
//       case 're_appointment':
//         route = userType == '0' ? '/consultation' : '/mytreatment';
//         shouldPreserveStack = true; // Preserve stack so user can go back
//         break;
//       case 'new_prescription':
//         route = userType == '0' ? '/doctormainscreen' : '/mytreatment';
//         shouldPreserveStack = false; // Go to home, clear stack
//         break;
//       case 'lab_upload':
//         route = userType == '0' ? '/consultation' : '/mainscreen';
//         shouldPreserveStack = false; // Go to home, clear stack
//         break;
//       case 'Test':
//         route = userType == '0' ? '/doctormainscreen' : '/mainscreen';
//         shouldPreserveStack = false; // Go to home, clear stack
//         break;
//       case 'remmembaring_appointment':
//         // LabsRecordScreen is a widget, not a route, so we'll handle it differently
//         if (userType == '0') {
//           route = '/notificationscreen';
//           shouldPreserveStack = false;
//         } else {
//           // For patients, we'll navigate to home and let them access labs from there
//           route = '/notificationscreen';
//           shouldPreserveStack = false;
//         }
//         break;
//       default:
//         print("Unhandled notification type: $type");
//         // Default route based on user type
//         route = userType == '0' ? '/doctormainscreen' : '/mainscreen';
//         shouldPreserveStack = false; // Go to home, clear stack
//         break;
//     }

//     print("Navigating to route: $route (preserveStack: $shouldPreserveStack)");
    
//     // Use different navigation strategies based on the notification type
//     if (Get.currentRoute != route) {
//       _navigateToRoute(route, shouldPreserveStack, userType);
//     }
//   }

//   /// Helper method to handle navigation with proper stack management
//   void _navigateToRoute(String route, bool shouldPreserveStack, String userType) {
//     print("🔔 NAVIGATION DEBUG: Starting navigation");
//     print("📱 Route: $route");
//     print("📱 Preserve Stack: $shouldPreserveStack");
//     print("📱 User Type: $userType");
//     print("📱 Current Route: ${Get.currentRoute}");
    
//     if (shouldPreserveStack) {
//       // For screens that should allow back navigation (like /mytreatment, /labs)
//       String homeRoute = userType == '0' ? '/doctormainscreen' : '/mainscreen';
      
//       if (Get.currentRoute != homeRoute) {
//         // If we're not on the home screen, go to home first
//         print("🔔 NAVIGATION DEBUG: Not on home screen, navigating to home first: $homeRoute");
//         Get.offAllNamed(homeRoute);
//         // Then push the target screen after a short delay
//         Future.delayed(Duration(milliseconds: 100), () {
//           print("🔔 NAVIGATION DEBUG: Pushing target screen: $route");
//           Get.toNamed(route);
//         });
//       } else {
//         // If we're already on the home screen, just push the target screen
//         print("🔔 NAVIGATION DEBUG: Already on home, pushing target screen: $route");
//         Get.toNamed(route);
//       }
//     } else {
//       // For home screen navigation, clear the stack
//       print("🔔 NAVIGATION DEBUG: Clearing stack and navigating to: $route");
//       Get.offAllNamed(route);
//     }
//   }
// }
import 'dart:io';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:tele/services/notification_service.dart';
import 'package:tele/services/notification_debug_helper.dart';
import 'package:tele/services/notification_manager.dart';

class FirebaseNotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GlobalKey<NavigatorState> navigatorKey;
  bool _isAppInForeground = true;

  FirebaseNotificationHandler(this.navigatorKey);

  Future<void> initNotification() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await NotificationDebugHelper.logNotificationEvent(
          'Local notification tapped',
          {'payload': response.payload, 'actionId': response.actionId},
        );
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final payloadData = jsonDecode(response.payload!) as Map<String, dynamic>;
            Map<String, dynamic>? notificationData;
            if (payloadData.containsKey('notificationId')) {
              final notificationId = payloadData['notificationId'] as int;
              notificationData = await NotificationManager.getNotificationData(notificationId);
              await NotificationManager.removeActiveNotification(notificationId);
            }
            final dataToUse = notificationData ?? payloadData;
            await NotificationDebugHelper.logNotificationEvent(
              'Using notification data',
              {'source': notificationData != null ? 'manager' : 'payload', 'data': dataToUse},
            );
            await handleNotificationNavigation(dataToUse);
          } catch (e) {
            print("Error parsing notification payload: $e");
            await handleNotificationNavigation({'type': response.payload});
          }
        }
      },
    );

    FirebaseMessaging.onMessage.listen((message) async {
      await NotificationDebugHelper.logNotificationEvent(
        'Foreground message received',
        message.data,
      );

      // Skip showing foreground notifications for call-related messages
      // These are handled by the CallKit service
      final messageType = message.data['type'];
      if (messageType == 'call_invitation' || messageType == 'call_end' || messageType == 'call_accepted') {
        print("🔔 DEBUG: Skipping foreground notification for call-related message: $messageType");
        return;
      }

      if (_isAppInForeground) {
        print("🔔 DEBUG: App is in foreground - showing local notification for: $messageType");
        _showLocalNotification(message);
      } else {
        print("🔔 DEBUG: App is in background - skipping local notification (system will show)");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print("🔔 DEBUG: onMessageOpenedApp triggered - background notification tapped");
      await NotificationDebugHelper.logNotificationEvent(
        'App opened from background via notification',
        message.data,
      );
      await handleNotificationNavigation(message.data);
    });

    final androidPlugin = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final channels = await androidPlugin.getNotificationChannels();
      print("🔔 DEBUG: Available notification channels: ${channels?.length ?? 0}");
      for (final channel in channels ?? []) {
        print("🔔 DEBUG: Channel: ${channel.id} - ${channel.name} - ${channel.importance}");
      }
    }

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("🔔 DEBUG: getInitialMessage found - terminated notification tapped");
      await NotificationDebugHelper.logNotificationEvent(
        'App launched by notification',
        initialMessage.data,
      );
      await handleNotificationNavigation(initialMessage.data);
    } else {
      print("🔔 DEBUG: getInitialMessage returned null - no terminated notification");
    }
  }

  void setAppState(bool isInForeground) {
    _isAppInForeground = isInForeground;
    print("🔔 DEBUG: App state changed - Foreground: $_isAppInForeground");
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notificationId = message.data['type'].hashCode +
        DateTime.now().millisecondsSinceEpoch ~/ 10000;

    await NotificationManager.storeActiveNotification(notificationId, message.data);

    final androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
      channelShowBadge: true,
      autoCancel: false,
      ongoing: false,
      enableVibration: true,
      playSound: true,
      ticker: 'New notification received',
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      usesChronometer: false,
      fullScreenIntent: false,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'open_action',
          'Open',
          showsUserInterface: true,
        ),
      ],
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    final title = message.data['title'] ?? 'New Notification';
    final body = message.data['body'] ?? 'Tap to open';

    final payload = jsonEncode({
      'notificationId': notificationId,
      ...message.data,
    });

    print("Showing local notification with ID: $notificationId");
    print("Payload: $payload");

    await _localNotificationsPlugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: payload,
    );

    await NotificationService.storePendingNotification(message.data);
  }

  Future<void> handleNotificationNavigation(Map<String, dynamic> data) async {
    await NotificationDebugHelper.logNotificationEvent(
      'Handling notification navigation',
      data,
    );

    await Future.delayed(Duration(milliseconds: 500));

    final context = navigatorKey.currentContext;
    if (context == null) {
      print("Context unavailable - storing notification for later");
      await NotificationService.storePendingNotification(data);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');

    if (userType == null) {
      print("User type not found in SharedPreferences");
      await NotificationDebugHelper.logNotificationEvent(
        'User type not found - storing for later',
        data,
      );
      await NotificationService.storePendingNotification(data);
      return;
    }

    final type = data['type']?.toString();
    await NotificationDebugHelper.logNotificationEvent(
      'Ready to navigate',
      {'type': type, 'userType': userType},
    );

    _redirectBasedOnUserType(context, type, userType);
  }

  void _redirectBasedOnUserType(
      BuildContext context, String? type, String userType) {
    String route;
    bool shouldPreserveStack = false;

    switch (type) {
      case 'appointment_booking':
        route = userType == '0' ? '/consultation' : '/mainscreen';
        break;
      case 'appointment_completed':
        route = userType == '0' ? '/doctormainscreen' : '/mytreatment';
        break;
      case 're_appointment':
        route = userType == '0' ? '/consultation' : '/mytreatment';
        shouldPreserveStack = true;
        break;
      case 'new_prescription':
        route = userType == '0' ? '/doctormainscreen' : '/mytreatment';
        break;
      case 'lab_upload':
        route = userType == '0' ? '/consultation' : '/mainscreen';
        break;
      case 'Test':
        route = userType == '0' ? '/doctormainscreen' : '/mainscreen';
        break;
      case 'remmembaring_appointment':
        route = '/notificationscreen';
        break;
      default:
        print("Unhandled notification type: $type");
        route = userType == '0' ? '/doctormainscreen' : '/mainscreen';
        break;
    }

    print("Navigating to route: $route (preserveStack: $shouldPreserveStack)");

    if (Get.currentRoute != route) {
      _navigateToRoute(route, shouldPreserveStack, userType);
    }
  }

  void _navigateToRoute(String route, bool shouldPreserveStack, String userType) {
    print("🔔 NAVIGATION DEBUG: Starting navigation");
    print("📱 Route: $route");
    print("📱 Preserve Stack: $shouldPreserveStack");
    print("📱 User Type: $userType");
    print("📱 Current Route: ${Get.currentRoute}");

    if (shouldPreserveStack) {
      String homeRoute = userType == '0' ? '/doctormainscreen' : '/mainscreen';

      if (Get.currentRoute != homeRoute) {
        Get.offAllNamed(homeRoute);
        Future.delayed(Duration(milliseconds: 100), () {
          Get.toNamed(route);
        });
      } else {
        Get.toNamed(route);
      }
    } else {
      Get.offAllNamed(route);
    }
  }
}