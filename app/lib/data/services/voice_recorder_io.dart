import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'voice_recorder.dart';

VoiceRecorderService createPlatformVoiceRecorderService() =>
    IoVoiceRecorderService();

class IoVoiceRecorderService implements VoiceRecorderService {
  static const MethodChannel _channel = MethodChannel(
    'dreemworld/voice_recorder',
  );

  bool _recording = false;

  @override
  bool get isSupported => true;

  @override
  bool get isRecording => _recording;

  @override
  Future<void> start() async {
    if (_recording) return;
    try {
      await _channel.invokeMethod<void>('start');
      _recording = true;
    } on PlatformException catch (error) {
      _recording = false;
      throw VoiceRecorderException(
        error.message ?? 'Не удалось начать запись голоса.',
      );
    } catch (_) {
      _recording = false;
      throw const VoiceRecorderException('Не удалось начать запись голоса.');
    }
  }

  @override
  Future<VoiceRecordResult?> stop() async {
    if (!_recording) return null;
    _recording = false;
    try {
      final Map<Object?, Object?>? result = await _channel
          .invokeMapMethod<Object?, Object?>('stop');
      if (result == null) return null;
      final String? dataUri = result['dataUri'] as String?;
      if (dataUri == null || dataUri.isEmpty) return null;
      final int durationMs = (result['durationMs'] as num?)?.toInt() ?? 0;
      final String mimeType = (result['mimeType'] as String?) ?? 'audio/mp4';
      final String base64Part = dataUri.contains(',')
          ? dataUri.substring(dataUri.indexOf(',') + 1)
          : dataUri;
      final Uint8List bytes = Uint8List.fromList(
        const Base64Decoder().convert(base64Part),
      );
      return VoiceRecordResult(
        bytes: bytes,
        durationMs: durationMs,
        mimeType: mimeType,
      );
    } on PlatformException catch (error) {
      throw VoiceRecorderException(
        error.message ?? 'Не удалось сохранить запись.',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cancel() async {
    _recording = false;
    try {
      await _channel.invokeMethod<void>('cancel');
    } catch (_) {}
  }

  @override
  void dispose() {
    if (_recording) {
      unawaited(cancel());
    }
  }
}
