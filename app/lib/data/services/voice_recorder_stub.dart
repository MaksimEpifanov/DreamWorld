import 'voice_recorder.dart';

VoiceRecorderService createPlatformVoiceRecorderService() =>
    StubVoiceRecorderService();

class StubVoiceRecorderService implements VoiceRecorderService {
  bool _recording = false;

  @override
  bool get isSupported => false;

  @override
  bool get isRecording => _recording;

  @override
  Future<void> start() async {
    throw UnsupportedError('Запись голоса не поддерживается на этой платформе');
  }

  @override
  Future<VoiceRecordResult?> stop() async {
    _recording = false;
    return null;
  }

  @override
  Future<void> cancel() async {
    _recording = false;
  }

  @override
  void dispose() {}
}
