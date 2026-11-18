// Этот файл подключается только на веб через условный импорт, поэтому
// использование веб-библиотек здесь безопасно и намеренно.
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'notification_service.dart';

/// Уведомления в браузере: звук и всплывающий баннер о новом сообщении.
///
/// Звук синтезируется на лету через Web Audio — без аудиофайлов и новых
/// зависимостей. Браузеры не дают воспроизводить звук до первого действия
/// пользователя, поэтому аудиоконтекст создаётся лениво и «разблокируется»
/// при первом касании или нажатии клавиши.
NotificationService createPlatformNotificationService() =>
    WebNotificationService();

class WebNotificationService implements NotificationService {
  web.AudioContext? _audio;
  bool _initialized = false;
  bool _permissionRequested = false;
  bool _unlockInstalled = false;
  JSFunction? _unlockPointer;
  JSFunction? _unlockKey;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _installUnlockListener();
    await _requestPermission();
  }

  @override
  Future<void> showMessageNotification({
    required String conversationId,
    required String title,
    required String body,
  }) async {
    _playSound();
    _showBanner(conversationId, title, body);
  }

  @override
  Future<void> cancelAll() async {}

  /// Разрешает звук после первого действия пользователя на странице.
  void _installUnlockListener() {
    if (_unlockInstalled) return;
    _unlockInstalled = true;
    void unlock(web.Event _) => _removeUnlockListener();
    try {
      _unlockPointer = unlock.toJS;
      _unlockKey = unlock.toJS;
      web.document.addEventListener('pointerdown', _unlockPointer);
      web.document.addEventListener('keydown', _unlockKey);
    } catch (_) {
      _unlockPointer = null;
      _unlockKey = null;
    }
  }

  void _removeUnlockListener() {
    _resumeAudio();
    final JSFunction? pointer = _unlockPointer;
    final JSFunction? key = _unlockKey;
    try {
      if (pointer != null) {
        web.document.removeEventListener('pointerdown', pointer);
      }
      if (key != null) {
        web.document.removeEventListener('keydown', key);
      }
    } catch (_) {}
    _unlockPointer = null;
    _unlockKey = null;
  }

  web.AudioContext? _ensureAudio() {
    final web.AudioContext? existing = _audio;
    if (existing != null) return existing;
    try {
      final web.AudioContext context = web.AudioContext();
      _audio = context;
      return context;
    } catch (_) {
      return null;
    }
  }

  void _resumeAudio() {
    final web.AudioContext? context = _audio ?? _ensureAudio();
    if (context == null) return;
    try {
      if (context.state == 'suspended') {
        context.resume();
      }
    } catch (_) {}
  }

  /// Короткий двухтональный сигнал.
  void _playSound() {
    final web.AudioContext? context = _ensureAudio();
    if (context == null) return;
    _resumeAudio();
    try {
      final double now = context.currentTime;
      _playTone(context, now, 880, 0.12);
      _playTone(context, now + 0.13, 1174.66, 0.22);
    } catch (_) {}
  }

  void _playTone(
    web.AudioContext context,
    double start,
    double frequency,
    double duration,
  ) {
    final web.OscillatorNode oscillator = context.createOscillator();
    final web.GainNode gain = context.createGain();
    oscillator.type = 'sine';
    oscillator.frequency.setValueAtTime(frequency, start);
    gain.gain.setValueAtTime(0.0001, start);
    gain.gain.exponentialRampToValueAtTime(0.25, start + 0.02);
    gain.gain.exponentialRampToValueAtTime(0.0001, start + duration);
    oscillator.connect(gain);
    gain.connect(context.destination);
    oscillator.start(start);
    oscillator.stop(start + duration + 0.02);
  }

  Future<void> _requestPermission() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    try {
      if (web.Notification.permission == 'default') {
        await web.Notification.requestPermission().toDart;
      }
    } catch (_) {}
  }

  void _showBanner(String conversationId, String title, String body) {
    try {
      if (web.Notification.permission != 'granted') return;
      web.Notification(
        title,
        web.NotificationOptions(body: body, tag: conversationId, silent: true),
      );
    } catch (_) {}
  }
}
