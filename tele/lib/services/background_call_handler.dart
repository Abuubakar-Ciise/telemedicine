import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:uuid/uuid.dart';
import 'package:tele/views/screens/components/config.dart';

class BackgroundCallHandler {
  static bool _isCallActive = false;
  static String? _activeCallId;

  static bool get isCallActive => _isCallActive;
  static String? get activeCallId => _activeCallId;

  @pragma('vm:entry-point')
  static Future<void> handleBackgroundCall(RemoteMessage message) async {
    await Config.ensureLoaded();
    try {
      // Initialize Firebase if not already initialized
      try {
        // Check if Firebase is already initialized
        Firebase.app();
        print('🔔 Firebase already initialized');
      } catch (e) {
        // Firebase not initialized, initialize it
        print('🔔 Initializing Firebase for background handler');
        await Firebase.initializeApp(options: Config.firebaseOptions);
        print('🔔 Firebase initialized successfully');
      }

      final data = message.data;
      print('🔔 Background call handler - Message type: ${data['type']}');

      switch (data['type']) {
        case 'call_invitation':
          await _handleBackgroundCallInvitation(data);
          break;
        case 'call_end':
          await _handleBackgroundCallEnd(data);
          break;
        case 'call_accepted':
          await _handleBackgroundCallAccepted(data);
          break;
        default:
          print('🔔 Unhandled background message type: ${data['type']}');
      }
    } catch (e) {
      print('❌ Error in background call handler: $e');
      print('❌ Error details: ${e.toString()}');
      
      // Fallback: try to show CallKit without Firebase dependency
      if (message.data['type'] == 'call_invitation') {
        await _handleBackgroundCallInvitationFallback(message.data);
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundCallInvitation(Map<String, dynamic> data) async {
    try {
      // Check if there's already an active call
      if (_isCallActive) {
        print('🔔 Call already active, ignoring new invitation');
        return;
      }

      print('🔔 Processing background call invitation');
      
      final uuid = const Uuid().v4();
      _activeCallId = uuid;
      _isCallActive = true;

      // Prepare avatar URL
      final picture = data['picture'] ?? '';
      final avatarUrl = picture.startsWith('http') 
          ? picture 
          : picture.isNotEmpty 
              ? '${Config.baseUrl}/$picture'
              : '';

      // Create CallKit parameters
      final params = CallKitParams(
        id: uuid,
        nameCaller: data['callerName'] ?? 'Unknown Caller',
        appName: 'Tayo healthcare',
        avatar: avatarUrl,
        handle: data['callerPhone'] ?? '',
        type: int.tryParse(data['callType'] ?? '0') ?? 0,
        duration: 30000,
        textAccept: 'Accept',
        textDecline: 'Decline',
        extra: {
          'roomId': data['roomId'] ?? '',
          'callerToken': data['callerToken'] ?? '',
          'calleeToken': data['calleeToken'] ?? '',
          'callType': data['callType'] ?? '0',
          'doctor_id': data['doctor_id'] ?? '',
          'patient_id': data['patient_id'] ?? '',
          'isIncoming': 'true',
          'isCaller': 'false',
        },
        headers: <String, dynamic>{'apiKey': 'Abc@123'},
      );

      // Show CallKit incoming call
      await FlutterCallkitIncoming.showCallkitIncoming(params);
      print('🔔 Background CallKit shown successfully with ID: $uuid');

    } catch (e) {
      print('❌ Error showing background CallKit: $e');
      _resetCallState();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundCallEnd(Map<String, dynamic> data) async {
    try {
      print('🔔 Processing background call end');
      
      if (_activeCallId != null) {
        await FlutterCallkitIncoming.endCall(_activeCallId!);
      }
      await FlutterCallkitIncoming.endAllCalls();
      
      _resetCallState();
      print('🔔 Background call ended successfully');
    } catch (e) {
      print('❌ Error ending background call: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundCallAccepted(Map<String, dynamic> data) async {
    try {
      print('🔔 Processing background call accepted');
      // Handle call accepted logic if needed
    } catch (e) {
      print('❌ Error handling background call accepted: $e');
    }
  }

  static void _resetCallState() {
    _activeCallId = null;
    _isCallActive = false;
  }

  static void setCallActive(bool active, [String? callId]) {
    _isCallActive = active;
    _activeCallId = callId;
  }

  static void clearCallState() {
    _resetCallState();
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundCallInvitationFallback(Map<String, dynamic> data) async {
    try {
      print('🔔 Using fallback method for background call invitation');
      
      // Check if there's already an active call
      if (_isCallActive) {
        print('🔔 Call already active, ignoring new invitation');
        return;
      }

      final uuid = const Uuid().v4();
      _activeCallId = uuid;
      _isCallActive = true;

      // Prepare avatar URL with fallback
      final picture = data['picture'] ?? '';
      final avatarUrl = picture.startsWith('http') 
          ? picture 
          : picture.isNotEmpty 
              ? 'https://your-default-domain.com/$picture' // Fallback URL
              : '';

      // Create CallKit parameters with minimal dependencies
      final params = CallKitParams(
        id: uuid,
        nameCaller: data['callerName'] ?? 'Unknown Caller',
        appName: 'Tayo healthcare',
        avatar: avatarUrl,
        handle: data['callerPhone'] ?? '',
        type: int.tryParse(data['callType'] ?? '0') ?? 0,
        duration: 30000,
        textAccept: 'Accept',
        textDecline: 'Decline',
        extra: {
          'roomId': data['roomId'] ?? '',
          'callerToken': data['callerToken'] ?? '',
          'calleeToken': data['calleeToken'] ?? '',
          'callType': data['callType'] ?? '0',
          'doctor_id': data['doctor_id'] ?? '',
          'patient_id': data['patient_id'] ?? '',
          'isIncoming': 'true',
          'isCaller': 'false',
        },
        headers: <String, dynamic>{'apiKey': 'Abc@123'},
      );

      // Show CallKit incoming call
      await FlutterCallkitIncoming.showCallkitIncoming(params);
      print('🔔 Fallback CallKit shown successfully with ID: $uuid');

    } catch (e) {
      print('❌ Error in fallback CallKit handler: $e');
      _resetCallState();
    }
  }
}