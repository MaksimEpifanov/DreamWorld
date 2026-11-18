import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_io.dart';

/// Локальные уведомления о новых сообщениях.
///
/// На Android и iOS показывают системное уведомление со звуком, пока приложение
/// запущено (в том числе свёрнуто). На веб локальные уведомления не нужны —
/// используется заглушка.
abstract interface class NotificationService {
  /// Готовит канал уведомлений и запрашивает разрешение.
  ///
  /// Безопасно вызывать повторно. Ошибки не пробрасываются: если платформа
  /// недоступна, сервис просто ничего не делает.
  Future<void> initialize();

  /// Показывает уведомление о новом сообщении.
  ///
  /// [conversationId] служит ключом уведомления: повторные сообщения одного
  /// диалога заменяют предыдущее уведомление, а не плодят новые.
  Future<void> showMessageNotification({
    required String conversationId,
    required String title,
    required String body,
  });

  /// Убирает все показанные уведомления.
  Future<void> cancelAll();
}

/// Создаёт сервис уведомлений для текущей платформы.
NotificationService createNotificationService() =>
    createPlatformNotificationService();
