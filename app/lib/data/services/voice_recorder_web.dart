import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'voice_recorder.dart';

VoiceRecorderService createPlatformVoiceRecorderService() =>
    WebVoiceRecorderService();

class WebVoiceRecorderService implements VoiceRecorderService {
  web.MediaRecorder? _recorder;
  web.MediaStream? _stream;
  final List<web.Blob> _chunks = <web.Blob>[];
  Completer<VoiceRecordResult?>? _stopCompleter;
  DateTime? _startedAt;
  bool _recording = false;

  @override
  bool get isSupported => true;

  @override
  bool get isRecording => _recording;

  @override
  Future<void> start() async {
    if (_recording) return;
    _chunks.clear();
    _stopCompleter = Completer<VoiceRecordResult?>();
    final web.MediaStreamConstraints constraints = web.MediaStreamConstraints(
      audio: true.toJS,
    );
    try {
      final JSPromise<web.MediaStream> promise = web
          .window
          .navigator
          .mediaDevices
          .getUserMedia(constraints);
      _stream = await promise.toDart;
    } catch (error) {
      _stopCompleter = null;
      _cleanupStream();
      throw VoiceRecorderException(_describeStartError(error));
    }

    web.MediaRecorder recorder;
    try {
      final String? mimeType = _pickSupportedMimeType();
      if (mimeType == null) {
        recorder = web.MediaRecorder(_stream!);
      } else {
        final web.MediaRecorderOptions options = web.MediaRecorderOptions(
          mimeType: mimeType,
        );
        recorder = web.MediaRecorder(_stream!, options);
      }
    } catch (error) {
      _stopCompleter = null;
      _cleanupStream();
      throw VoiceRecorderException(
        'Браузер не поддерживает запись голоса: $error',
      );
    }
    _recorder = recorder;

    recorder.addEventListener(
      'dataavailable',
      ((web.Event event) {
        final web.BlobEvent e = event as web.BlobEvent;
        final web.Blob data = e.data;
        if (data.size > 0) _chunks.add(data);
      }).toJS,
    );

    recorder.addEventListener(
      'stop',
      ((web.Event _) {
        _handleStop();
      }).toJS,
    );

    recorder.addEventListener(
      'error',
      ((web.Event _) {
        _finishStop(null);
      }).toJS,
    );

    _startedAt = DateTime.now();
    _recording = true;
    recorder.start();
  }

  static String? _pickSupportedMimeType() {
    const List<String> candidates = <String>[
      'audio/mp4;codecs=mp4a.40.2',
      'audio/mp4',
      'audio/aac',
      'audio/webm;codecs=opus',
      'audio/webm',
    ];
    for (final String type in candidates) {
      try {
        if (web.MediaRecorder.isTypeSupported(type)) return type;
      } catch (_) {}
    }
    return null;
  }

  String _describeStartError(Object error) {
    final String text = error.toString();
    if (text.contains('NotAllowedError') ||
        text.contains('Permission denied') ||
        text.contains('denied')) {
      return 'Разрешите доступ к микрофону в браузере и попробуйте снова.';
    }
    if (text.contains('NotFoundError') || text.contains('Devices not found')) {
      return 'Микрофон не найден. Подключите микрофон и попробуйте снова.';
    }
    if (text.contains('NotReadableError')) {
      return 'Микрофон занят другим приложением. Закройте его и попробуйте снова.';
    }
    if (text.contains('SecurityError') ||
        text.contains('secure context') ||
        text.contains('mediaDevices')) {
      return 'Запись голоса требует HTTPS или localhost. Откройте сайт через http://localhost:8087 или HTTPS.';
    }
    return 'Не удалось начать запись голоса: $text';
  }

  Future<void> _handleStop() async {
    try {
      final int durationMs = _startedAt == null
          ? 0
          : DateTime.now().difference(_startedAt!).inMilliseconds;
      if (_chunks.isEmpty) {
        _finishStop(null);
        return;
      }
      final web.Blob blob = web.Blob(
        _chunks.map((web.Blob b) => b as JSAny).toList().toJS,
        web.BlobPropertyBag(type: _mimeType),
      );
      final JSArrayBuffer buffer = await blob.arrayBuffer().toDart;
      final Uint8List bytes = buffer.toDart.asUint8List();
      _finishStop(
        VoiceRecordResult(
          bytes: bytes,
          durationMs: durationMs,
          mimeType: _mimeType,
        ),
      );
    } catch (_) {
      _finishStop(null);
    } finally {
      _cleanupStream();
    }
  }

  String get _mimeType {
    final String? type = _recorder?.mimeType;
    if (type != null && type.isNotEmpty) return type;
    return 'audio/webm';
  }

  void _finishStop(VoiceRecordResult? result) {
    _recording = false;
    final Completer<VoiceRecordResult?>? completer = _stopCompleter;
    _stopCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete(result);
  }

  void _cleanupStream() {
    final web.MediaStream? stream = _stream;
    _stream = null;
    if (stream == null) return;
    try {
      final JSArray<web.MediaStreamTrack> tracks = stream.getTracks();
      for (int i = 0; i < tracks.toDart.length; i++) {
        tracks.toDart[i].stop();
      }
    } catch (_) {}
  }

  @override
  Future<VoiceRecordResult?> stop() async {
    if (!_recording) return null;
    final web.MediaRecorder? recorder = _recorder;
    final Completer<VoiceRecordResult?>? completer = _stopCompleter;
    if (recorder == null || completer == null) {
      _recording = false;
      _cleanupStream();
      return null;
    }
    try {
      if (recorder.state != 'inactive') recorder.stop();
    } catch (_) {
      _finishStop(null);
      _cleanupStream();
      return null;
    }
    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        _cleanupStream();
        return null;
      },
    );
  }

  @override
  Future<void> cancel() async {
    if (!_recording) {
      _cleanupStream();
      return;
    }
    _recording = false;
    final Completer<VoiceRecordResult?>? completer = _stopCompleter;
    _stopCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete(null);
    try {
      final web.MediaRecorder? recorder = _recorder;
      if (recorder != null && recorder.state != 'inactive') recorder.stop();
    } catch (_) {}
    _chunks.clear();
    _cleanupStream();
  }

  @override
  void dispose() {
    unawaited(cancel());
  }
}
