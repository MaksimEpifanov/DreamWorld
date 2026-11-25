import 'voice_recorder_stub.dart'
    if (dart.library.io) 'voice_recorder_io.dart'
    if (dart.library.js_interop) 'voice_recorder_web.dart';

class VoiceRecordResult {
  const VoiceRecordResult({
    required this.bytes,
    required this.durationMs,
    required this.mimeType,
  });

  final List<int> bytes;
  final int durationMs;
  final String mimeType;
}

abstract interface class VoiceRecorderService {
  bool get isSupported;
  bool get isRecording;
  Future<void> start();
  Future<VoiceRecordResult?> stop();
  Future<void> cancel();
  void dispose();
}

VoiceRecorderService createVoiceRecorderService() =>
    createPlatformVoiceRecorderService();

/// Ошибка запуска записи с понятным для пользователя текстом.
class VoiceRecorderException implements Exception {
  const VoiceRecorderException(this.message);

  final String message;

  @override
  String toString() => message;
}
