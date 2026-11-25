import 'voice_player_stub.dart'
    if (dart.library.io) 'voice_player_io.dart'
    if (dart.library.js_interop) 'voice_player_web.dart';

abstract class VoicePlayer {
  bool get isPlaying;
  int get positionMs;
  int get durationMs;
  Stream<void> get changes;
  Future<void> setSource(String url);
  Future<void> play();
  Future<void> pause();
  Future<void> seekMs(int ms);
  void dispose();
}

VoicePlayer createVoicePlayer() => createPlatformVoicePlayer();
