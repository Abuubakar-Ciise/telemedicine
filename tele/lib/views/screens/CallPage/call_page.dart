import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:tele/services/StorageService.dart';
import 'package:tele/services/call_session.dart';
import 'package:tele/services/firebase_api.dart';
import 'package:tele/views/screens/CallPage/call_helpers.dart';
import 'package:tele/views/screens/components/config.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const _bgTop = Color(0xFF0B3D2E);
const _bgBottom = Color(0xFF04140F);
const _accent = Color(0xFF34C759);
const _danger = Color(0xFFE5484D);

/// One-to-one voice/video consultation call.
class CallPage extends StatefulWidget {
  final String callId;

  /// '0' = voice, '1' = video
  final String callType;

  /// The other person in the call (shown while ringing and during voice calls).
  final String peerName;
  final String peerPicture;

  /// true for the person who started the call.
  final bool isCaller;

  /// Who to tell if the caller hangs up before the call is answered.
  final String? calleeType;
  final String? calleeId;
  final String doctorId;
  final String patientId;

  /// Number of call screens currently open (used to avoid closing other screens).
  static int openCount = 0;

  static _CallPageState? _active;

  /// Ends the open call properly (leaves the Zego room and closes the screen).
  static void endActive([String? message]) => _active?._endCall(message);

  const CallPage({
    super.key,
    required this.callId,
    required this.callType,
    this.peerName = '',
    this.peerPicture = '',
    this.isCaller = false,
    this.calleeType,
    this.calleeId,
    this.doctorId = '',
    this.patientId = '',
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  String? _myId;
  String _myName = '';
  String _myPicture = '';

  final _remoteJoined = ValueNotifier<bool>(false);
  final _elapsed = ValueNotifier<Duration>(Duration.zero);
  Timer? _ticker;
  Timer? _noAnswer;
  Timer? _statusWatch;
  bool _ended = false;
  bool _cancelSent = false;
  bool _micOn = true;
  bool _speakerOn = false;

  bool get _isVideo => widget.callType == '1';

  @override
  void initState() {
    super.initState();
    CallPage.openCount++;
    CallPage._active = this;
    _speakerOn = _isVideo;
    _loadMe();

    // Follow the call's state on the server for the WHOLE call, on both phones:
    // declined / cancelled / missed / ended by the other person -> end here too,
    // even if no push notification reaches this phone.
    _statusWatch = CallSession.watch(widget.callId, (status) {
      if (_remoteJoined.value) {
        _endCall(status == 'ended' ? 'Call ended' : null);
      } else {
        _endCall(switch (status) {
          'declined' => 'Call declined',
          'cancelled' => 'Call cancelled',
          'ended' => 'Call ended',
          _ => 'No answer',
        });
      }
    });

    // Give up if nobody joins
    _noAnswer = Timer(const Duration(seconds: 50), () {
      if (!_remoteJoined.value) {
        if (widget.isCaller) CallSession.update(widget.callId, 'missed');
        _endCall(widget.isCaller ? 'No answer' : 'Could not connect');
      }
    });
  }

  Future<void> _loadMe() async {
    final data = await StorageService.getUserData();
    if (!mounted) return;
    setState(() {
      // Zego user IDs must be unique per person: use the account id.
      _myId = (data['userId'] ?? '').isNotEmpty
          ? data['userId']!
          : 'guest_${DateTime.now().millisecondsSinceEpoch}';
      _myName = (data['username'] ?? '').isNotEmpty ? data['username']! : 'Me';
      _myPicture = data['picture'] ?? '';
    });
  }

  void _onRemoteJoined() {
    if (_remoteJoined.value || _ended) return;
    // Zego also reports our own entry: make sure someone else is really here
    if (ZegoUIKit().getRemoteUsers().isEmpty) return;
    _remoteJoined.value = true;
    _noAnswer?.cancel();
    final start = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed.value = DateTime.now().difference(start);
    });
  }

  /// Ends the call properly: leaves the Zego room (Zego blocks a plain "back"),
  /// then closes this screen. Safe to call more than once.
  Future<void> _endCall([String? message]) async {
    if (_ended || !mounted) return;
    _ended = true;
    _noAnswer?.cancel();
    _statusWatch?.cancel();
    _ticker?.cancel();
    if (message != null) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(message)));
    }
    try {
      await ZegoUIKitPrebuiltCallController()
          .hangUp(context, showConfirmation: false);
    } catch (e) {
      debugPrint('Zego hangUp failed: $e');
    }
    _removeThisScreen();
  }

  /// Removes this screen even though Zego blocks the Back action.
  void _removeThisScreen() {
    if (!mounted) return;
    final route = ModalRoute.of(context);
    if (route != null && route.isActive)
      Navigator.of(context).removeRoute(route);
  }

  /// End button on the waiting screen (before the other person answers).
  void _hangUpWhileWaiting() {
    if (widget.isCaller) _cancelForCallee();
    _endCall();
  }

  void _cancelForCallee() {
    if (_cancelSent) return;
    _cancelSent = true;
    CallSession.update(widget.callId, 'cancelled');
    if (widget.calleeType != null && widget.calleeId != null) {
      FirebaseApis().sendCallCancelled(
        calleeType: widget.calleeType!,
        calleeId: widget.calleeId!,
        doctorId: widget.doctorId,
        patientId: widget.patientId,
        roomId: widget.callId,
      );
    }
  }

  @override
  void dispose() {
    CallPage.openCount--;
    if (CallPage._active == this) CallPage._active = null;
    _ticker?.cancel();
    _noAnswer?.cancel();
    _statusWatch?.cancel();
    if (_remoteJoined.value) {
      CallSession.update(widget.callId, 'ended');
    } else if (widget.isCaller) {
      _cancelForCallee(); // closed before an answer (no-op if already sent)
    }
    // Clear the phone's own call state ("ongoing call" notification)
    FlutterCallkitIncoming.endAllCalls();
    _remoteJoined.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  ZegoUIKitPrebuiltCallConfig _buildConfig() {
    final config = _isVideo
        ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    // No picture-in-picture: it kept calls alive in the background
    config.pip = ZegoCallPIPConfig(enableWhenBackground: false);
    config.topMenuBar.isVisible = false;
    config.duration.isVisible = false; // our own timer is shown in the header
    config.audioVideoView.showUserNameOnView = false;
    config.audioVideoView.showAvatarInAudioMode = true;
    config.audioVideoView.showSoundWavesInAudioMode = true;
    config.useSpeakerWhenJoining = _isVideo;

    config.bottomMenuBar
      ..style = ZegoCallMenuBarStyle.dark
      ..hideAutomatically = false
      ..buttons = _isVideo
          ? const [
              ZegoCallMenuBarButtonName.toggleCameraButton,
              ZegoCallMenuBarButtonName.toggleMicrophoneButton,
              ZegoCallMenuBarButtonName.hangUpButton,
              ZegoCallMenuBarButtonName.switchAudioOutputButton,
              ZegoCallMenuBarButtonName.switchCameraButton,
            ]
          : const [
              ZegoCallMenuBarButtonName.toggleMicrophoneButton,
              ZegoCallMenuBarButtonName.hangUpButton,
              ZegoCallMenuBarButtonName.switchAudioOutputButton,
            ];

    const gradient = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, _bgBottom],
        ),
      ),
    );
    config.background = gradient;
    // Each person's tile too (Zego's default is plain grey)
    config.audioVideoView.backgroundBuilder =
        (context, size, user, extraInfo) => gradient;

    config.avatarBuilder = (context, size, user, extraInfo) {
      final isMe = user?.id == _myId;
      return _Avatar(
        name: isMe
            ? _myName
            : (widget.peerName.isNotEmpty
                ? widget.peerName
                : (user?.name ?? '')),
        picture: isMe ? _myPicture : widget.peerPicture,
        size: size.shortestSide,
      );
    };
    return config;
  }

  @override
  Widget build(BuildContext context) {
    if (_myId == null) {
      return const Scaffold(
        backgroundColor: _bgBottom,
        body: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    return PopScope(
      canPop: false, // Back = hang up
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_remoteJoined.value) {
          _endCall();
        } else {
          _hangUpWhileWaiting();
        }
      },
      child: Scaffold(
        backgroundColor: _bgBottom,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // The call itself always fills the whole screen
            Positioned.fill(
              child: SafeArea(
                top:
                    false, // video edge-to-edge at the top, buttons clear of the gesture bar
                child: ZegoUIKitPrebuiltCall(
                  appID: Config.appId,
                  appSign: Config.appSign,
                  callID: widget.callId,
                  userID: _myId!,
                  userName: _myName,
                  config: _buildConfig(),
                  events: ZegoUIKitPrebuiltCallEvents(
                    user: ZegoCallUserEvents(
                      // Zego also reports our own entry: only the other person counts
                      onEnter: (user) {
                        if (user.id != _myId) _onRemoteJoined();
                      },
                    ),
                    // Other person hung up, or the Zego hang-up button was pressed
                    onCallEnd: (event, defaultAction) {
                      _ended = true;
                      _noAnswer?.cancel();
                      _statusWatch?.cancel();
                      _ticker?.cancel();
                      defaultAction.call();
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _removeThisScreen());
                    },
                  ),
                ),
              ),
            ),

            // Name + timer pill (top-left, never over the self-view in the top-right)
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _remoteJoined,
                    builder: (context, joined, _) {
                      if (!joined) return const SizedBox.shrink();
                      return Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                _isVideo
                                    ? Icons.videocam_rounded
                                    : Icons.call_rounded,
                                color: _accent,
                                size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                widget.peerName.isNotEmpty
                                    ? widget.peerName
                                    : 'Consultation',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ValueListenableBuilder<Duration>(
                              valueListenable: _elapsed,
                              builder: (context, d, _) => Text(
                                _format(d),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Full-screen waiting view (covers everything until the other person joins)
            Positioned.fill(
              child: ValueListenableBuilder<bool>(
                valueListenable: _remoteJoined,
                builder: (context, joined, _) => IgnorePointer(
                  ignoring: joined,
                  child: AnimatedOpacity(
                    opacity: joined ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    child: _WaitingView(
                      name: widget.peerName,
                      picture: widget.peerPicture,
                      status: widget.isCaller
                          ? (_isVideo ? 'Video calling...' : 'Calling...')
                          : 'Connecting...',
                      micOn: _micOn,
                      speakerOn: _speakerOn,
                      onToggleMic: () {
                        setState(() => _micOn = !_micOn);
                        ZegoUIKit().turnMicrophoneOn(_micOn);
                      },
                      onToggleSpeaker: () {
                        setState(() => _speakerOn = !_speakerOn);
                        ZegoUIKit().setAudioOutputToSpeaker(_speakerOn);
                      },
                      onHangUp: _hangUpWhileWaiting,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _WaitingView extends StatefulWidget {
  final String name;
  final String picture;
  final String status;
  final bool micOn;
  final bool speakerOn;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onHangUp;

  const _WaitingView({
    required this.name,
    required this.picture,
    required this.status,
    required this.micOn,
    required this.speakerOn,
    required this.onToggleMic,
    required this.onToggleSpeaker,
    required this.onHangUp,
  });

  @override
  State<_WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends State<_WaitingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
            const Spacer(flex: 2),
            SizedBox(
              width: 220,
              height: 220,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) => Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final offset in [0.0, 0.5])
                      Builder(builder: (_) {
                        final t = (_pulse.value + offset) % 1.0;
                        return Container(
                          width: 120 + 100 * t,
                          height: 120 + 100 * t,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _accent.withValues(alpha: 0.25 * (1 - t)),
                          ),
                        );
                      }),
                    child!,
                  ],
                ),
                child: _Avatar(
                    name: widget.name, picture: widget.picture, size: 120),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.name.isNotEmpty ? widget.name : 'Consultation',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.status,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75), fontSize: 16)),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CircleButton(
                    icon: widget.micOn
                        ? Icons.mic_rounded
                        : Icons.mic_off_rounded,
                    label: widget.micOn ? 'Mute' : 'Unmute',
                    background: Colors.white
                        .withValues(alpha: widget.micOn ? 0.14 : 0.85),
                    iconColor: widget.micOn ? Colors.white : _bgBottom,
                    onTap: widget.onToggleMic,
                  ),
                  _CircleButton(
                    icon: Icons.call_end_rounded,
                    label: 'End',
                    background: _danger,
                    iconColor: Colors.white,
                    size: 76,
                    onTap: widget.onHangUp,
                  ),
                  _CircleButton(
                    icon: widget.speakerOn
                        ? Icons.volume_up_rounded
                        : Icons.hearing_rounded,
                    label: widget.speakerOn ? 'Speaker' : 'Earpiece',
                    background: Colors.white
                        .withValues(alpha: widget.speakerOn ? 0.85 : 0.14),
                    iconColor: widget.speakerOn ? _bgBottom : Colors.white,
                    onTap: widget.onToggleSpeaker,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;
  final double size;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.iconColor,
    required this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
                width: size,
                height: size,
                child: Icon(icon, color: iconColor, size: size * 0.45)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String picture;
  final double size;
  const _Avatar(
      {required this.name, required this.picture, required this.size});

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final url = resolvePictureUrl(picture);
    final fallback = Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient:
            LinearGradient(colors: [Color(0xFF1FA34A), Color(0xFF0E6B2C)]),
      ),
      child: Text(
        _initials,
        style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700),
      ),
    );
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2),
      ),
      child: ClipOval(
        child: url.isEmpty
            ? fallback
            : Image.network(url,
                fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback),
      ),
    );
  }
}
