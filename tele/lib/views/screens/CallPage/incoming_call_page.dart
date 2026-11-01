import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:tele/services/call_session.dart';
import 'package:tele/services/firebase_api.dart';
import 'package:tele/views/screens/CallPage/call_helpers.dart';

const _bgTop = Color(0xFF0B3D2E);
const _bgBottom = Color(0xFF04140F);
const _accent = Color(0xFF34C759);

/// Full-screen incoming call shown *inside the app* (when the app is open).
/// When the app is in the background, closed or the phone is locked, the
/// system call screen (CallKit) is used instead.
class IncomingCallPage extends StatefulWidget {
  /// The `data` of the call_invitation push.
  final Map<String, dynamic> data;

  const IncomingCallPage({super.key, required this.data});

  static _IncomingCallPageState? _current;

  /// True while an incoming call screen is showing.
  static bool get isShowing => _current != null;

  /// Close the screen (e.g. the caller hung up before it was answered).
  static void dismiss({String? roomId}) {
    final state = _current;
    if (state == null) return;
    if (roomId != null && roomId.isNotEmpty && state.roomId != roomId) return;
    state._close(missed: true);
  }

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();
  Timer? _timeout;
  Timer? _statusWatch;
  bool _closed = false;

  String get roomId => (widget.data['roomId'] ?? '').toString();
  String get _name => (widget.data['callerName'] ?? '').toString();
  String get _picture => (widget.data['picture'] ?? '').toString();
  bool get _isVideo => (widget.data['callType'] ?? '0').toString() == '1';

  @override
  void initState() {
    super.initState();
    IncomingCallPage._current = this;
    FlutterRingtonePlayer().playRingtone(looping: true);
    _timeout = Timer(const Duration(seconds: 45), () => _close(missed: true));
    // Caller hung up / call expired: stop ringing even if no push arrives
    _statusWatch = CallSession.watch(roomId, (_) => _close(missed: true));
  }

  void _stopRinging() {
    _timeout?.cancel();
    _statusWatch?.cancel();
    FlutterRingtonePlayer().stop();
  }

  void _close({bool missed = false}) {
    if (_closed) return;
    _closed = true;
    _stopRinging();
    if (mounted) {
      _removeSelf();
      if (missed) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
              content: Text(
                  'Missed call from ${_name.isEmpty ? 'your doctor' : _name}')),
        );
      }
    }
  }

  void _accept() {
    if (_closed) return;
    _closed = true;
    _stopRinging();
    _removeSelf();
    openCallScreen(Map<String, dynamic>.from(
        widget.data)); // also marks the call "answered"
  }

  void _decline() {
    if (_closed) return;
    final callerType = (widget.data['callerType'] ?? 'doctor').toString();
    final doctorId = (widget.data['doctor_id'] ?? '').toString();
    final patientId = (widget.data['patient_id'] ?? '').toString();
    // The caller's screen checks this every 2 s, so it closes even without push
    CallSession.update(roomId, 'declined');
    FirebaseApis().sendCallEndTo(
      toType: callerType,
      toId: callerType == 'doctor' ? doctorId : patientId,
      doctorId: doctorId,
      patientId: patientId,
      roomId: roomId,
    );
    _close();
  }

  /// This screen blocks the Back button (answer or decline), so close it directly.
  void _removeSelf() {
    final route = ModalRoute.of(context);
    if (route != null && route.isActive)
      Navigator.of(context).removeRoute(route);
  }

  @override
  void dispose() {
    if (IncomingCallPage._current == this) IncomingCallPage._current = null;
    _stopRinging();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = resolvePictureUrl(_picture);
    final initials = _name.trim().isEmpty
        ? '?'
        : _name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join();

    return PopScope(
      canPop: false, // answer or decline
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_bgTop, _bgBottom],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  _isVideo
                      ? 'Incoming video consultation'
                      : 'Incoming voice consultation',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 15,
                      letterSpacing: 0.3),
                ),
                const Spacer(),
                SizedBox(
                  width: 240,
                  height: 240,
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) => Stack(
                      alignment: Alignment.center,
                      children: [
                        for (final offset in [0.0, 0.5])
                          Builder(builder: (_) {
                            final t = (_pulse.value + offset) % 1.0;
                            return Container(
                              width: 130 + 110 * t,
                              height: 130 + 110 * t,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _accent.withValues(alpha: 0.25 * (1 - t)),
                              ),
                            );
                          }),
                        child!,
                      ],
                    ),
                    child: Container(
                      width: 130,
                      height: 130,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.85),
                            width: 2),
                      ),
                      child: ClipOval(
                        child: url.isEmpty
                            ? _Initials(initials)
                            : Image.network(url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _Initials(initials)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _name.isEmpty ? 'Tayo Health' : _name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Text('is calling you…',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 16)),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundAction(
                        color: const Color(0xFFE5484D),
                        icon: Icons.call_end_rounded,
                        label: 'Decline',
                        onTap: _decline,
                      ),
                      _RoundAction(
                        color: _accent,
                        icon: _isVideo
                            ? Icons.videocam_rounded
                            : Icons.call_rounded,
                        label: 'Accept',
                        onTap: _accept,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String text;
  const _Initials(this.text);

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xFF1FA34A), Color(0xFF0E6B2C)]),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w700)),
      );
}

class _RoundAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _RoundAction(
      {required this.color,
      required this.icon,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: color.withValues(alpha: 0.5),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
                width: 76,
                height: 76,
                child: Icon(icon, color: Colors.white, size: 34)),
          ),
        ),
        const SizedBox(height: 10),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
