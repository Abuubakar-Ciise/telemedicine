// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_callkit_incoming/entities/entities.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:tele/main.dart';
// import 'package:tele/services/firebase_api.dart';
// import 'package:tele/views/screens/CallPage/call_page.dart';
// import 'package:tele/views/screens/CallPage/callkit_service.dart';
// import 'package:tele/views/screens/components/config.dart';

// @pragma('vm:entry-point')
// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: FirebaseOptions(
//       apiKey: Config.firebaseapkey,
//       appId: Config.firebaseappid,
//       messagingSenderId: Config.firebasemessagingsenderid,
//       projectId: Config.firebaseprojectid,
//     ),
//   );
//   final data = message.data;
//   if (data['type'] == 'call_invitation' && !CallKitService.isCallActive) {
//     await CallKitService.showCallkit(
//       data['callerName'],
//       data['roomId'],
//       data['picture'],
//       data['callerToken'],
//       data['calleeToken'],
//       data['callerPhone'],
//       data['callType'],
//       data['doctor_id'] ?? '',
//       data['patient_id'] ?? '',
//       isIncoming: true,
//     );
//   } else if (data['type'] == 'call_end') {
//     await CallKitService.endAllCalls(
//       data['doctor_id'] ?? '',
//       data['patient_id'] ?? '',
//       callId: data['call_id'] ?? '',
//     );
//   } else if (data['type'] == 'call_accepted') {
//     CallKitService.setCallAccepted();
//   }
// }

// class FirebaseNotification {
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> initNotification() async {
//     await _firebaseMessaging.requestPermission();
//     await _firebaseMessaging.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     FirebaseMessaging.onMessage.listen(_handleMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
//     await _checkInitialMessage();

//     _setupCallKitListeners();
//   }

//   void _setupCallKitListeners() {
//     FlutterCallkitIncoming.onEvent.listen((event) async {
//       final eventType = event?.event;
//       final isIncoming = event?.body['extra']?['isIncoming'] == 'true';
//       final isCaller = event?.body['extra']?['isCaller'] == 'true';

//       switch (eventType) {
//         case Event.actionCallAccept:
//           _handleCallAccept(event!);
//           break;

//         case Event.actionCallDecline:
//           await _handleCallDecline(event!);
//           break;

//         case Event.actionCallEnded:
//           if (isCaller) {
//             await _handleCallerCancellation(event!);
//           } else {
//             if (isIncoming && CallKitService.isCallActive) {
//               await _handleCallEnded(event!);
//             }
//           }
//           break;

//         default:
//           print("Unhandled CallKit event: $eventType");
//       }
//     });
//   }

//   void _handleCallAccept(CallEvent event) {
//     CallKitService.clearCallId();
//     final roomId = event.body['extra']?['roomId'];
//     final callType = event.body['extra']?['callType'];
//     final callerToken = event.body['extra']?['callerToken'];
//     final doctorId = event.body['extra']?['doctor_id'] ?? '';
//     final patientId = event.body['extra']?['patient_id'] ?? '';

//     if (callerToken != null) {
//       FirebaseApis().sendCallAcceptedFCM(callerToken, doctorId, patientId);
//     }

//     if (roomId != null && callType != null) {
//       _navigateToCallScreen(roomId, callType);
//     }
//   }

//   Future<void> _handleCallDecline(CallEvent event) async {
//     final callerToken = event.body['extra']?['callerToken'];
//     final calleeToken = event.body['extra']?['calleeToken'];
//     final doctorId = event.body['extra']?['doctor_id'] ?? '';
//     final patientId = event.body['extra']?['patient_id'] ?? '';
//     final callId = event.body['id'];

//     if (callerToken != null && calleeToken != null) {
//       try {
//         await FirebaseApis().sendCallEndToBothFCM(
//           callerToken,
//           calleeToken,
//           doctorId,
//           patientId,
//           callId,
//         );
//       } catch (e) {
//         print("Error sending decline FCM to both: $e");
//       }
//     }

//     await CallKitService.endAllCalls(doctorId, patientId, callId: callId);
//   }

//   Future<void> _handleCallEnded(CallEvent event) async {
//     final callerToken = event.body['extra']?['callerToken'];
//     final calleeToken = event.body['extra']?['calleeToken'];
//     final doctorId = event.body['extra']?['doctor_id'] ?? '';
//     final patientId = event.body['extra']?['patient_id'] ?? '';
//     final callId = event.body['id'];

//     if (callerToken != null && calleeToken != null && CallKitService.isIncoming) {
//       try {
//         await FirebaseApis().sendCallEndToBothFCM(
//           callerToken,
//           calleeToken,
//           doctorId,
//           patientId,
//           callId,
//         );
//       } catch (e) {
//         print("Error sending ended FCM to both: $e");
//       }
//     }

//     await CallKitService.endAllCalls(doctorId, patientId, callId: callId);
//   }

//   Future<void> _handleCallerCancellation(CallEvent event) async {
//     final calleeToken = event.body['extra']?['calleeToken'];
//     final doctorId = event.body['extra']?['doctor_id'] ?? '';
//     final patientId = event.body['extra']?['patient_id'] ?? '';
//     final callId = event.body['id'];

//     if (calleeToken != null) {
//       await FirebaseApis().sendCallEndFCM(
//         calleeToken,
//         doctorId,
//         patientId,
//         callId,
//       );
//     }
//     await CallKitService.endAllCalls(doctorId, patientId, callId: callId);
//   }

//   void _handleMessage(RemoteMessage message) {
//     final data = message.data;
//     if (data['type'] == 'call_invitation' && !CallKitService.isCallActive) {
//       CallKitService.showCallkit(
//         data['callerName'],
//         data['roomId'],
//         data['picture'],
//         data['callerToken'],
//         data['calleeToken'],
//         data['callerPhone'],
//         data['callType'],
//         data['doctor_id'] ?? '',
//         data['patient_id'] ?? '',
//         isIncoming: true,
//       );
//     } else if (data['type'] == 'call_end') {
//       CallKitService.endAllCalls(
//         data['doctor_id'] ?? '',
//         data['patient_id'] ?? '',
//         callId: data['call_id'] ?? '',
//       );
//     } else if (data['type'] == 'call_accepted') {
//       CallKitService.setCallAccepted();
//     }
//   }

//   Future<void> _checkInitialMessage() async {
//     final message = await _firebaseMessaging.getInitialMessage();
//     if (message != null) _handleMessage(message);
//   }

//   void _navigateToCallScreen(String roomId, String callType) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       CallKitService.setCallAccepted();
//       navigatorKey.currentState?.push(
//         MaterialPageRoute(
//           builder: (_) => CallPage(callId: roomId, callType: callType),
//         ),
//       );
//     });
//   }
// }

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:tele/main.dart';
import 'package:tele/services/firebase_api.dart';
import 'package:tele/views/screens/CallPage/call_page.dart';
import 'package:tele/views/screens/CallPage/callkit_service.dart';
import 'package:tele/views/screens/CallPage/call_helpers.dart';
import 'package:tele/services/call_session.dart';
import 'package:tele/views/screens/CallPage/incoming_call_page.dart';

// Background message handler is now handled in main.dart
// This duplicate handler has been removed to avoid conflicts

class FirebaseNotification {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    await _checkInitialMessage();

    _setupCallKitListeners();
  }

  void _setupCallKitListeners() {
    FlutterCallkitIncoming.onEvent.listen((event) async {
      final eventType = event?.event;
      final isIncoming = event?.body['extra']?['isIncoming'] == 'true';
      final isCaller = event?.body['extra']?['isCaller'] == 'true';

      switch (eventType) {
        case Event.actionCallAccept:
          _handleCallAccept(event!);
          break;

        case Event.actionCallDecline:
          await _handleCallDecline(event!);
          break;

        case Event.actionCallTimeout:
          // Unanswered call rang out: reset so the next call is not ignored
          CallSession.update(
              (event?.body['extra']?['roomId'] ?? '').toString(), 'missed');
          CallKitService.clearCallId();
          break;

        case Event.actionCallEnded:
          if (isCaller) {
            await _handleCallerCancellation(event!);
          } else {
            if (isIncoming && CallKitService.isCallActive) {
              await _handleCallEnded(event!);
            }
          }
          break;

        default:
          print("Unhandled CallKit event: $eventType");
      }
    });
  }

  void _handleCallAccept(CallEvent event) {
    CallKitService.clearCallId();
    final roomId = event.body['extra']?['roomId'];
    final callType = event.body['extra']?['callType'];
    final callerToken = event.body['extra']?['callerToken'];
    final doctorId = event.body['extra']?['doctor_id'] ?? '';
    final patientId = event.body['extra']?['patient_id'] ?? '';

    if (callerToken != null) {
      FirebaseApis().sendCallAcceptedFCM(callerToken, doctorId, patientId);
    }

    if (roomId != null && callType != null) {
      CallKitService.setCallAccepted();
      openCallScreen(Map<String, dynamic>.from(event.body['extra'] ?? {})
        ..putIfAbsent('callerName', () => event.body['nameCaller'] ?? ''));
    }
  }

  Future<void> _handleCallDecline(CallEvent event) async {
    final doctorId = event.body['extra']?['doctor_id'] ?? '';
    final patientId = event.body['extra']?['patient_id'] ?? '';
    final callId = event.body['id'];

    // Record it on the server: the caller's screen checks this every 2 s
    CallSession.update(
        (event.body['extra']?['roomId'] ?? '').toString(), 'declined');
    // Tell the caller (looked up by account id, so a stale token doesn't matter)
    final callerType =
        (event.body['extra']?['callerType'] ?? 'doctor').toString();
    await FirebaseApis().sendCallEndTo(
      toType: callerType,
      toId: callerType == 'doctor' ? doctorId : patientId,
      doctorId: doctorId,
      patientId: patientId,
      roomId: (event.body['extra']?['roomId'] ?? '').toString(),
    );

    await CallKitService.endAllCalls(doctorId, patientId, callId: callId);
  }

  Future<void> _handleCallEnded(CallEvent event) async {
    final callerToken = event.body['extra']?['callerToken'];
    final calleeToken = event.body['extra']?['calleeToken'];
    final doctorId = event.body['extra']?['doctor_id'] ?? '';
    final patientId = event.body['extra']?['patient_id'] ?? '';
    final callId = event.body['id'];

    if (callerToken != null &&
        calleeToken != null &&
        CallKitService.isIncoming) {
      try {
        await FirebaseApis().sendCallEndToBothFCM(
          callerToken,
          calleeToken,
          doctorId,
          patientId,
          callId,
        );
      } catch (e) {
        print("Error sending ended FCM to both: $e");
      }
    }

    await CallKitService.endAllCalls(doctorId, patientId, callId: callId);
  }

  Future<void> _handleCallerCancellation(CallEvent event) async {
    final calleeToken = event.body['extra']?['calleeToken'];
    final doctorId = event.body['extra']?['doctor_id'] ?? '';
    final patientId = event.body['extra']?['patient_id'] ?? '';
    final callId = event.body['id'];

    if (calleeToken != null) {
      await FirebaseApis().sendCallEndFCM(
        calleeToken,
        doctorId,
        patientId,
        callId,
      );
    }
    await CallKitService.endAllCalls(doctorId, patientId, callId: callId);
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    print('🔔 Foreground message received: ${data['type']}');

    if (data['type'] == 'call_invitation') {
      // App is open: show our own full-screen incoming call (system pop-ups are
      // often blocked on MIUI / ColorOS). Ignore if already ringing or in a call.
      if (IncomingCallPage.isShowing || CallPage.openCount > 0) {
        print('🔔 Busy: ignoring call invitation ${data['roomId']}');
        return;
      }
      print('🔔 Showing in-app incoming call');
      markIncomingCallShown((data['roomId'] ?? '').toString());
      navigatorKey.currentState?.push(
        MaterialPageRoute(
            builder: (_) =>
                IncomingCallPage(data: Map<String, dynamic>.from(data))),
      );
    } else if (data['type'] == 'call_end') {
      print('🔔 Handling foreground call end');
      IncomingCallPage.dismiss(roomId: data['roomId']);
      CallKitService.endAllCalls(
        data['doctor_id'] ?? '',
        data['patient_id'] ?? '',
        callId: data['call_id'] ?? '',
      );
    } else if (data['type'] == 'call_accepted') {
      print('🔔 Handling foreground call accepted');
      CallKitService.setCallAccepted();
    }
  }

  Future<void> _checkInitialMessage() async {
    final message = await _firebaseMessaging.getInitialMessage();
    if (message != null) _handleMessage(message);
  }

  void _navigateToCallScreen(String roomId, String callType) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CallKitService.setCallAccepted();
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => CallPage(callId: roomId, callType: callType),
        ),
      );
    });
  }
}
