import 'notification_service.dart';

/// Заглушка для платформ без поддержки уведомлений.
NotificationService createPlatformNotificationService() =>
    const _NoopNotificationService();

class _NoopNotificationService implements NotificationService {
  const _NoopNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showMessageNotification({
    required String conversationId,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelAll() async {}
}
