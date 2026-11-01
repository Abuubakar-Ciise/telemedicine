import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tele/views/screens/components/config.dart';

/// Server-side state of a call, so both phones always agree on what happened
/// (answered / declined / cancelled / missed / ended) even when a push
/// notification is lost or a phone has no Google Play services.
class CallSession {
  static const finalStates = {'declined', 'cancelled', 'missed', 'ended'};

  static Future<void> start({
    required String roomId,
    required String doctorId,
    required String patientId,
    required String callType,
    String callerType = 'doctor',
  }) =>
      _post('call_start', {
        'roomId': roomId,
        'doctor_id': doctorId,
        'patient_id': patientId,
        'call_type': callType,
        'caller_type': callerType,
      });

  /// status: answered | declined | cancelled | missed | ended
  static Future<void> update(String roomId, String status) =>
      roomId.isEmpty ? Future.value() : _post('call_update', {'roomId': roomId, 'status': status});

  static Future<String> status(String roomId) async {
    try {
      final res = await http
          .post(
            Uri.parse('${Config.baseUrl}/call_status'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'roomId': roomId}),
          )
          .timeout(const Duration(seconds: 6));
      return (jsonDecode(res.body)['status'] ?? 'unknown').toString();
    } catch (_) {
      return 'unknown';
    }
  }

  /// Calls [onFinal] once when the call reaches a final state. Cancel the timer when done.
  static Timer watch(String roomId, void Function(String status) onFinal) {
    var done = false;
    return Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (done) return;
      final s = await status(roomId);
      if (!done && finalStates.contains(s)) {
        done = true;
        timer.cancel();
        onFinal(s);
      }
    });
  }

  static Future<void> _post(String path, Map<String, dynamic> body) async {
    try {
      await http
          .post(
            Uri.parse('${Config.baseUrl}/$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      // ignore: avoid_print
      print('CallSession $path failed: $e');
    }
  }
}
