enum AppNotificationKind { community, event, recommendation, social, update }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.isRead,
    this.route,
  });

  final String id;
  final AppNotificationKind kind;
  final String title;
  final String description;
  final String timeLabel;
  final bool isRead;
  final String? route;

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    kind: kind,
    title: title,
    description: description,
    timeLabel: timeLabel,
    isRead: isRead ?? this.isRead,
    route: route,
  );
}
