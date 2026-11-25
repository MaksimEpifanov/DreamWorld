import 'dart:async';

import 'package:flutter/services.dart';

import 'voice_player.dart';

VoicePlayer createPlatformVoicePlayer() => IoVoicePlayer();

class IoVoicePlayer implements VoicePlayer {
  static const MethodChannel _channel = MethodChannel(
    'dreemworld/voice_player',
  );

  static IoVoicePlayer? _active;

  final StreamController<void> _changes = StreamController<void>.broadcast();
  bool _playing = false;
  int _positionMs = 0;
  int _durationMs = 0;

  IoVoicePlayer() {
    _channel.setMethodCallHandler(_handleCall);
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    if (_active != this) return;
    if (call.method != 'event') return;
    final Map<Object?, Object?> args =
        (call.arguments as Map<Object?, Object?>?) ?? <Object?, Object?>{};
    final String event = args['event'] as String? ?? '';
    final int pos = (args['positionMs'] as num?)?.toInt() ?? _positionMs;
    final int dur = (args['durationMs'] as num?)?.toInt() ?? _durationMs;
    _positionMs = pos;
    if (dur > 0) _durationMs = dur;
    if (event == 'completed') {
      _playing = false;
      _positionMs = _durationMs;
    } else if (event == 'paused') {
      _playing = false;
    } else if (event == 'error') {
      _playing = false;
    }
    _notify();
  }

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  @override
  bool get isPlaying => _playing;

  @override
  int get positionMs => _positionMs;

  @override
  int get durationMs => _durationMs;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> setSource(String url) async {
    _active = this;
    try {
      final Map<Object?, Object?>? result = await _channel
          .invokeMapMethod<Object?, Object?>('setSource', <String, Object?>{
            'url': url,
          });
      _durationMs = (result?['durationMs'] as num?)?.toInt() ?? 0;
      _positionMs = 0;
      _playing = false;
      _notify();
    } catch (_) {
      _durationMs = 0;
      _positionMs = 0;
      _playing = false;
      _notify();
    }
  }

  @override
  Future<void> play() async {
    _active = this;
    try {
      await _channel.invokeMethod<void>('play');
      _playing = true;
      _notify();
    } catch (_) {
      _playing = false;
      _notify();
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _channel.invokeMethod<void>('pause');
    } catch (_) {}
    _playing = false;
    _notify();
  }

  @override
  Future<void> seekMs(int ms) async {
    try {
      await _channel.invokeMethod<void>('seek', <String, Object?>{'ms': ms});
      _positionMs = ms;
      _notify();
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_active == this) {
      _active = null;
      try {
        _channel.invokeMethod<void>('release');
      } catch (_) {}
    }
    _changes.close();
  }
}
