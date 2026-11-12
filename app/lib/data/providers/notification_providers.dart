import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../repositories/mock_notification_repository.dart';
import '../repositories/notification_repository.dart';

final Provider<NotificationRepository> notificationRepositoryProvider =
    Provider<NotificationRepository>(
      (Ref ref) => const MockNotificationRepository(),
    );

final StateNotifierProvider<NotificationController, List<AppNotification>>
notificationControllerProvider =
    StateNotifierProvider<NotificationController, List<AppNotification>>((
      Ref ref,
    ) {
      return NotificationController(ref.watch(notificationRepositoryProvider));
    });

class NotificationController extends StateNotifier<List<AppNotification>> {
  NotificationController(NotificationRepository repository)
    : super(repository.getNotifications());

  void markRead(String id) {
    state = state
        .map(
          (AppNotification item) =>
              item.id == id ? item.copyWith(isRead: true) : item,
        )
        .toList(growable: false);
  }

  void markAllRead() {
    state = state
        .map((AppNotification item) => item.copyWith(isRead: true))
        .toList(growable: false);
  }
}
