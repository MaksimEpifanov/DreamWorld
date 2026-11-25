import 'dart:async';

import 'voice_player.dart';

VoicePlayer createPlatformVoicePlayer() => StubVoicePlayer();

class StubVoicePlayer implements VoicePlayer {
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  bool get isPlaying => false;

  @override
  int get positionMs => 0;

  @override
  int get durationMs => 0;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> setSource(String url) async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> seekMs(int ms) async {}

  @override
  void dispose() {
    _changes.close();
  }
}
