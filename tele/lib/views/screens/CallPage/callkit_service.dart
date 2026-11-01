// import 'package:flutter_callkit_incoming/entities/entities.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:tele/services/StorageService.dart';
// import 'package:tele/views/screens/components/config.dart';
// import 'package:tele/views/screens/patient/ReviewsScreen.dart';
// import 'package:uuid/uuid.dart';
import 'package:tele/views/screens/CallPage/call_helpers.dart';
import 'package:tele/views/screens/CallPage/call_page.dart';
// import 'package:flutter/material.dart';
// import 'package:tele/main.dart';

// class CallKitService {
//   static String? _activeCallId;
//   static String? url = Config.baseUrl;
//   static bool _isCallActive = false;
//   static bool _isIncoming = false;
//   static bool _callAccepted = false;

//   static void setCallAccepted() {
//     _callAccepted = true;
//   }

//   static Future<void> showCallkit(
//     String callerName,
//     String roomId,
//     String picture,
//     String callerToken,
//     String calleeToken,
//     String callerPhone,
//     String callType,
//     String doctorId,
//     String patientId,
//     {bool isIncoming = true, bool isCaller = false}
//   ) async {
//     if (_activeCallId != null && _isCallActive) {
//       print("Call already active with ID: $_activeCallId");
//       return;
//     }

//     final uuid = const Uuid().v4();
//     _activeCallId = uuid;
//     _isCallActive = true;
//     _isIncoming = isIncoming;
//     _callAccepted = false;
//     final avatarUrl = picture.startsWith('http') ? picture : '$url/$picture';

//     final params = CallKitParams(
//       id: uuid,
//       nameCaller: callerName,
//       appName: 'Tayo healthcare',
//       avatar: avatarUrl,
//       handle: callerPhone,
//       type: int.tryParse(callType) ?? 0,
//       duration: 30000,
//       textAccept: 'Accept',
//       textDecline: 'Decline',
//       extra: {
//         'roomId': roomId,
//         'callerToken': callerToken,
//         'calleeToken': calleeToken,
//         'callType': callType,
//         'doctor_id': doctorId,
//         'patient_id': patientId,
//         'isIncoming': isIncoming.toString(),
//         'isCaller': isCaller.toString(),
//       },
//       headers: <String, dynamic>{'apiKey': 'Abc@123'},
//     );

//     await FlutterCallkitIncoming.showCallkitIncoming(params);
//     print("CallKit incoming call shown with ID: $uuid");
//   }

//   // static Future<void> endAllCalls(
//   //   String doctorId,
//   //   String patientId, {
//   //   String callId = '',
//   // }) async {
//   //   try {
//   //     print('Ending all calls, activeCallId: $_activeCallId');
//   //     if (_activeCallId != null) {
//   //       await FlutterCallkitIncoming.endCall(_activeCallId!);
//   //     }
//   //     await FlutterCallkitIncoming.endAllCalls();
//   //     _resetCallState();

//   //     await Future.delayed(const Duration(milliseconds: 500));

//   //     WidgetsBinding.instance.addPostFrameCallback((_) async {
//   //       final navigator = navigatorKey.currentState;
//   //       if (navigator?.canPop() ?? false) {
//   //         navigator?.pop();
//   //       }

//   //       if (_callAccepted && _isIncoming) {
//   //         final userData = await StorageService.getUserData();
//   //         if (userData['userType'] == '1') {
//   //           final context = navigator?.overlay?.context;
//   //           if (context != null) {
//   //             await showModalBottomSheet(
//   //               context: context,
//   //               isScrollControlled: true,
//   //               backgroundColor: Colors.white,
//   //               builder: (_) => ReviewsScreen(
//   //                 doctorId: doctorId,
//   //                 patientId: patientId,
//   //               ),
//   //             );
//   //           }
//   //         }
//   //       }
//   //     });
//   //   } catch (e) {
//   //     print('Error ending calls: $e');
//   //     rethrow;
//   //   }
//   // }
//  static Future<void> endAllCalls(
//   String doctorId,
//   String patientId, {
//   String callId = '',
// }) async {
//   try {
//     print('Ending all calls, activeCallId: $_activeCallId');

//     if (_activeCallId != null) {
//       await FlutterCallkitIncoming.endCall(_activeCallId!);
//     }
//     await FlutterCallkitIncoming.endAllCalls();
//     _resetCallState();

//     final userData = await StorageService.getUserData();
//     final shouldShowReview = userData['userType'] == '1' && _callAccepted && _isIncoming;

//     final navigator = navigatorKey.currentState;
//     final context = navigatorKey.currentContext;

//     if (navigator?.canPop() ?? false) {
//       navigator?.pop();
//     }

//     if (shouldShowReview && context != null) {
//       // Delay to wait for navigation and avoid "context not mounted" error
//       Future.delayed(const Duration(milliseconds: 300), () {
//         final currentContext = navigatorKey.currentContext;
//         if (currentContext != null) {
//           showModalBottomSheet(
//             context: currentContext,
//             isScrollControlled: true,
//             backgroundColor: Colors.white,
//             builder: (_) => ReviewsScreen(
//               doctorId: doctorId,
//               patientId: patientId,
//             ),
//           );
//         } else {
//           print('❌ Could not get a valid context to show bottom sheet.');
//         }
//       });
//     }
//   } catch (e) {
//     print('❌ Error ending calls: $e');
//     rethrow;
//   }
// }

//   static void _resetCallState() {
//     _activeCallId = null;
//     _isCallActive = false;
//     _isIncoming = false;
//     _callAccepted = false;
//   }

//   static void clearCallId() {
//     _resetCallState();
//   }

//   static String? get activeCallId => _activeCallId;
//   static bool get isCallActive => _isCallActive;
//   static bool get isIncoming => _isIncoming;
// }
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/services/background_call_handler.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:tele/main.dart';
import 'package:uuid/uuid.dart';

class CallKitService {
  static String? _activeCallId;
  static bool _isCallActive = false;
  static bool _isIncoming = false;
  static bool _callAccepted = false;
  static String? get url => Config.baseUrl;

  static bool get isCallActive =>
      _isCallActive || BackgroundCallHandler.isCallActive;
  static bool get isIncoming => _isIncoming;

  static void setCallAccepted() {
    _callAccepted = true;
  }

  static void clearCallId() {
    _resetCallState();
    BackgroundCallHandler.clearCallState();
  }

  static void _resetCallState() {
    _activeCallId = null;
    _isCallActive = false;
    _isIncoming = false;
    _callAccepted = false;
  }

  static Future<void> showCallkit(
    String callerName,
    String roomId,
    String picture,
    String callerToken,
    String calleeToken,
    String callerPhone,
    String callType,
    String doctorId,
    String patientId, {
    bool isIncoming = true,
    bool isCaller = false,
    String callerType = 'doctor',
  }) async {
    if (_activeCallId != null && _isCallActive) return;

    final uuid = const Uuid().v4();
    _activeCallId = uuid;
    _isCallActive = true;
    _isIncoming = isIncoming;
    _callAccepted = false;

    final params = buildIncomingCallParams(
      id: uuid,
      callerName: callerName,
      picture: picture,
      callerPhone: callerPhone,
      callType: callType,
      extra: {
        'roomId': roomId,
        'callerToken': callerToken,
        'calleeToken': calleeToken,
        'callType': callType,
        'callerType': callerType,
        'doctor_id': doctorId,
        'patient_id': patientId,
        'isIncoming': isIncoming.toString(),
        'isCaller': isCaller.toString(),
      },
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  static Future<void> endAllCalls(
    String doctorId,
    String patientId, {
    String callId = '',
  }) async {
    try {
      print('🛑 Ending all calls');

      if (_activeCallId != null) {
        await FlutterCallkitIncoming.endCall(_activeCallId!);
      }
      await FlutterCallkitIncoming.endAllCalls();
      _isCallActive = false;

      final userData = await StorageService.getUserData();
      final shouldShowReview =
          _callAccepted && _isIncoming && userData['userType'] == '1';

      final navigator = navigatorKey.currentState;
      final context = navigator?.overlay?.context;

      // Only close the call screen (if one is open) - never another screen.
      // End the open call properly (a plain pop would leave the Zego room running)
      if (CallPage.openCount > 0) CallPage.endActive('Call ended');

      if (shouldShowReview && context != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          final currentContext = navigatorKey.currentContext;
          // if (currentContext != null) {
          //   showModalBottomSheet(
          //     context: currentContext,
          //     isScrollControlled: true,
          //     backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          //     builder: (_) => ReviewsScreen(
          //       doctorId: doctorId,
          //       patientId: patientId,
          //       appointmentId: appointmentId,
          //     ),
          //   );
          // } else {
          //   print('❌ No valid context to show ReviewsScreen.');
          // }
        });
      }

      _resetCallState();
    } catch (e) {
      print('❌ Error ending call: $e');
      rethrow;
    }
  }
}
