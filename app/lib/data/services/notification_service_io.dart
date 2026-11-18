import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

/// Локальные уведомления на Android и iOS через `flutter_local_notifications`.
NotificationService createPlatformNotificationService() =>
    LocalNotificationService();

class LocalNotificationService implements NotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String _channelId = 'dreem_messages';
  static const String _channelName = 'Сообщения';
  static const String _channelDescription =
      'Звуковые уведомления о новых сообщениях';

  bool _initialized = false;
  bool _available = false;

  bool get _supported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Зарегистрирован ли плагин на этой платформе (в тестах — нет).
  bool get _registered {
    try {
      FlutterLocalNotificationsPlatform.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (!_supported || !_registered) return;
    try {
      const InitializationSettings settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings: settings);
      await _requestPermission();
      _available = true;
    } catch (error) {
      _available = false;
      debugPrint('Локальные уведомления недоступны: $error');
    }
  }

  Future<void> _requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  @override
  Future<void> showMessageNotification({
    required String conversationId,
    required String title,
    required String body,
  }) async {
    if (!_available) return;
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
      playSound: true,
      enableVibration: true,
    );
    const DarwinNotificationDetails darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails details = NotificationDetails(
      android: android,
      iOS: darwin,
    );
    try {
      await _plugin.show(
        id: conversationId.hashCode & 0x7fffffff,
        title: title,
        body: body,
        notificationDetails: details,
        payload: conversationId,
      );
    } catch (error) {
      debugPrint('Не удалось показать уведомление: $error');
    }
  }

  @override
  Future<void> cancelAll() async {
    if (!_available) return;
    try {
      await _plugin.cancelAll();
    } catch (error) {
      debugPrint('Не удалось убрать уведомления: $error');
    }
  }
}
