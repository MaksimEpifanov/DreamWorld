import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'voice_player.dart';

VoicePlayer createPlatformVoicePlayer() => WebVoicePlayer();

class WebVoicePlayer implements VoicePlayer {
  final web.HTMLAudioElement _audio = web.HTMLAudioElement();
  final StreamController<void> _changes = StreamController<void>.broadcast();
  bool _playing = false;

  WebVoicePlayer() {
    _audio.addEventListener(
      'play',
      ((web.Event _) {
        _playing = true;
        _notify();
      }).toJS,
    );
    _audio.addEventListener(
      'pause',
      ((web.Event _) {
        _playing = false;
        _notify();
      }).toJS,
    );
    _audio.addEventListener(
      'ended',
      ((web.Event _) {
        _playing = false;
        _notify();
      }).toJS,
    );
    _audio.addEventListener(
      'timeupdate',
      ((web.Event _) {
        _notify();
      }).toJS,
    );
    _audio.addEventListener(
      'loadedmetadata',
      ((web.Event _) {
        _notify();
      }).toJS,
    );
    _audio.addEventListener(
      'durationchange',
      ((web.Event _) {
        _notify();
      }).toJS,
    );
  }

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  @override
  bool get isPlaying => _playing;

  @override
  int get positionMs => ((_audio.currentTime) * 1000).round();

  @override
  int get durationMs {
    final double d = _audio.duration;
    if (d.isNaN || d.isInfinite) return 0;
    return (d * 1000).round();
  }

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> setSource(String url) async {
    _audio.src = url;
    _audio.load();
  }

  @override
  Future<void> play() async {
    await _audio.play().toDart;
  }

  @override
  Future<void> pause() async {
    _audio.pause();
  }

  @override
  Future<void> seekMs(int ms) async {
    _audio.currentTime = ms / 1000.0;
  }

  @override
  void dispose() {
    try {
      _audio.pause();
    } catch (_) {}
    _audio.src = '';
    _changes.close();
  }
}
