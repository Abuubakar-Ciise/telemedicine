import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tele/main.dart';
import 'package:tele/services/call_session.dart';
import 'package:tele/views/screens/CallPage/call_page.dart';
import 'package:tele/views/screens/CallPage/incoming_call_page.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/views/screens/components/config.dart';

/// Brand colours used by the incoming-call screen.
const String _callBackground = '#0B3D2E';
const String _callAction = '#0E8A16';

/// "admin_profile/x.jpg" -> "http://192.168.100.8:2003/admin_profile/x.jpg"
String resolvePictureUrl(String? picture) {
  final p = (picture ?? '').trim();
  if (p.isEmpty || p == 'N/A') return '';
  if (p.startsWith('http')) return p;
  return '${Config.baseUrl}/${p.replaceFirst(RegExp(r'^/+'), '')}';
}

/// The full-screen incoming call (also shown on the lock screen and when the app is closed).
CallKitParams buildIncomingCallParams({
  required String id,
  required String callerName,
  required String picture,
  required String callerPhone,
  required String callType,
  required Map<String, dynamic> extra,
}) {
  final isVideo = callType == '1';
  return CallKitParams(
    id: id,
    nameCaller: callerName.isEmpty ? 'Tayo Health' : callerName,
    appName: 'Tayo Health',
    avatar: resolvePictureUrl(picture),
    handle:
        isVideo ? 'Incoming video consultation' : 'Incoming voice consultation',
    type: isVideo ? 1 : 0,
    duration: 45000, // ring for 45 seconds
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: const NotificationParams(
      showNotification: true,
      isShowCallback: false,
      subtitle: 'Missed consultation call',
    ),
    extra: {
      ...extra,
      'callerName': callerName,
      'picture': picture,
      'callerPhone': callerPhone,
      // When the call arrived: only recent calls may be (re)joined on app start
      'receivedAt': DateTime.now().millisecondsSinceEpoch.toString(),
    },
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      isShowCallID: false,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: _callBackground,
      actionColor: _callAction,
      textColor: '#FFFFFF',
      incomingCallNotificationChannelName: 'Incoming consultation calls',
      missedCallNotificationChannelName: 'Missed consultation calls',
      isShowFullLockedScreen: true,
      isImportant: true,
    ),
  );
}

String? _lastOpenedRoom;
const _handledRoomsKey = 'handled_call_rooms';
const _maxRejoinAge = Duration(minutes: 2);

Future<Set<String>> _handledRooms() async {
  final prefs = await SharedPreferences.getInstance();
  return (prefs.getStringList(_handledRoomsKey) ?? const []).toSet();
}

Future<void> _markHandled(String roomId) async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_handledRoomsKey) ?? <String>[];
  if (!list.contains(roomId)) list.add(roomId);
  // keep the list short
  await prefs.setStringList(_handledRoomsKey,
      list.length > 30 ? list.sublist(list.length - 30) : list);
}

/// Opens the call screen for an accepted call (once per room, ever).
void openCallScreen(Map<String, dynamic> extra) {
  final roomId = (extra['roomId'] ?? '').toString();
  if (roomId.isEmpty || roomId == _lastOpenedRoom) return;
  _lastOpenedRoom = roomId;
  _markHandled(roomId);
  CallSession.update(roomId, 'answered');
  _whenNavigatorReady((navigator) {
    navigator.push(
      MaterialPageRoute(
        builder: (_) => CallPage(
          callId: roomId,
          callType: (extra['callType'] ?? '0').toString(),
          peerName: (extra['callerName'] ?? '').toString(),
          peerPicture: (extra['picture'] ?? '').toString(),
          isCaller: false,
        ),
      ),
    );
  });
}

/// The app's navigator only exists once the main app has been built (not on the
/// first loading frame when the app was launched by an incoming call).
void _whenNavigatorReady(void Function(NavigatorState navigator) action,
    [int attempt = 0]) {
  final navigator = navigatorKey.currentState;
  if (navigator != null) {
    action(navigator);
  } else if (attempt < 50) {
    Future.delayed(const Duration(milliseconds: 200),
        () => _whenNavigatorReady(action, attempt + 1));
  }
}

/// When the app was closed and the user tapped "Accept", Android starts the app
/// *after* the accept event fired. Look for an accepted call and join it.
Future<void> openAcceptedCallIfAny() async {
  try {
    final calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is! List) return;
    final handled = await _handledRooms();
    final now = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic>? toOpen;

    for (final call in calls) {
      if (call is! Map) continue;
      final extra = Map<String, dynamic>.from((call['extra'] as Map?) ?? {});
      final receivedAt = int.tryParse((extra['receivedAt'] ?? '').toString());
      final age =
          receivedAt == null ? null : Duration(milliseconds: now - receivedAt);
      final stale = age == null || age > _maxRejoinAge;
      final roomId = (extra['roomId'] ?? '').toString();

      if (call['isAccepted'] == true &&
          !stale &&
          !handled.contains(roomId) &&
          toOpen == null) {
        extra.putIfAbsent('callerName', () => call['nameCaller'] ?? '');
        toOpen = extra;
      } else if (stale ||
          (call['isAccepted'] == true && handled.contains(roomId))) {
        // Old call left over from an earlier session: forget it.
        final id = (call['id'] ?? '').toString();
        if (id.isNotEmpty) await FlutterCallkitIncoming.endCall(id);
      }
    }
    if (toOpen != null) openCallScreen(toOpen);
  } catch (e) {
    debugPrint('⚠️ openAcceptedCallIfAny: $e');
  }
}

/// One-time setup so calls can ring when the phone is locked or the app is closed:
///  1. full-screen incoming calls (Android 14+)
///  2. no battery optimisation (Android may otherwise delay/kill the app)
///  3. auto-start / background activity (Xiaomi, OPPO, Vivo... block closed apps)
Future<void> ensureFullScreenCallPermission() async {
  if (!Platform.isAndroid) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('call_setup_done_v2') == true) return;

    final fullScreenOk =
        (await FlutterCallkitIncoming.canUseFullScreenIntent()) == true;
    final batteryOk = await Permission.ignoreBatteryOptimizations.isGranted;

    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    final go = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.phone_in_talk_rounded,
            color: Color(0xFF0E8A16), size: 32),
        title: const Text('Never miss a call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'So doctors and patients can reach you even when the phone is locked or Tayo is closed:'),
            const SizedBox(height: 12),
            _SetupStep(
                done: fullScreenOk, text: 'Allow full-screen incoming calls'),
            _SetupStep(
                done: batteryOk,
                text: 'Turn off battery optimisation for Tayo'),
            const _SetupStep(
                done: false,
                text:
                    'Turn on "Autostart" / "Allow background activity" in the app settings'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Later')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Set up')),
        ],
      ),
    );
    if (go != true) return;
    await prefs.setBool('call_setup_done_v2', true);

    if (!fullScreenOk)
      await FlutterCallkitIncoming.requestFullIntentPermission();
    if (!batteryOk) await Permission.ignoreBatteryOptimizations.request();
    // Autostart has no standard API: open Tayo's settings page
    await openAppSettings();
  } catch (e) {
    debugPrint('⚠️ call setup: $e');
  }
}

class _SetupStep extends StatelessWidget {
  final bool done;
  final String text;
  const _SetupStep({required this.done, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: done ? const Color(0xFF0E8A16) : Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

// ---------------- In-app incoming-call check ----------------
// While the app is open, ask the server every 3 s whether someone is calling.
// This makes calls ring even on phones where push notifications don't work
// (e.g. no Google Play services). Push still handles the closed/locked case.
Timer? _incomingPoller;
final Set<String> _shownRooms = {};

void startIncomingCallPoller() {
  _incomingPoller?.cancel();
  _incomingPoller = Timer.periodic(const Duration(seconds: 3), (_) => _checkIncomingCall());
}

Future<void> _checkIncomingCall() async {
  try {
    final state = WidgetsBinding.instance.lifecycleState;
    if (state != null && state != AppLifecycleState.resumed) return; // app not on screen
    if (IncomingCallPage.isShowing || CallPage.openCount > 0) return; // already ringing / in a call

    final user = await StorageService.getUserData();
    final userId = user['userId'] ?? '';
    final userType = user['userType'] == '0' ? 'doctor' : (user['userType'] == '1' ? 'patient' : '');
    if (userId.isEmpty || userType.isEmpty) return; // not logged in

    final res = await http
        .post(
          Uri.parse('${Config.baseUrl}/call_incoming'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId, 'user_type': userType}),
        )
        .timeout(const Duration(seconds: 6));
    final call = jsonDecode(res.body)['call'];
    if (call is! Map) return;
    final data = Map<String, dynamic>.from(call);
    final roomId = (data['roomId'] ?? '').toString();
    if (roomId.isEmpty || _shownRooms.contains(roomId)) return;
    if ((await _handledRooms()).contains(roomId)) return;
    if (IncomingCallPage.isShowing || CallPage.openCount > 0) return;

    _shownRooms.add(roomId);
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => IncomingCallPage(data: data)),
    );
  } catch (_) {
    // offline / server unreachable: try again on the next tick
  }
}

/// Mark a room as already shown (e.g. it rang through a push notification).
void markIncomingCallShown(String roomId) {
  if (roomId.isNotEmpty) _shownRooms.add(roomId);
}
