import '../models/app_notification.dart';

abstract class NotificationRepository {
  List<AppNotification> getNotifications();
}
