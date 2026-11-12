import '../models/app_notification.dart';
import 'notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  const MockNotificationRepository();

  @override
  List<AppNotification> getNotifications() => const <AppNotification>[
    AppNotification(
      id: 'planet-cinema-news',
      kind: AppNotificationKind.community,
      title: 'Новое в планете «Кино»',
      description: 'Участники обсуждают премьеры этой недели.',
      timeLabel: '5 минут назад',
      isRead: false,
      route: '/main/planet/p_cinema/news',
    ),
    AppNotification(
      id: 'travel-meetup',
      kind: AppNotificationKind.event,
      title: 'Скоро событие: прогулка выходного дня',
      description:
          'Путешественники собираются в субботу. Загляни в новости планеты.',
      timeLabel: '24 минуты назад',
      isRead: false,
      route: '/main/planet/p_travel/news',
    ),
    AppNotification(
      id: 'nature-new-members',
      kind: AppNotificationKind.community,
      title: 'Новые участники в планете «Природа»',
      description: 'К сообществу присоединились люди с похожими интересами.',
      timeLabel: '1 час назад',
      isRead: false,
      route: '/main/planet/p_nature',
    ),
    AppNotification(
      id: 'interest-recommendation',
      kind: AppNotificationKind.recommendation,
      title: 'Подобрали новые миры для тебя',
      description: 'Посмотри сообщества, которые подходят твоим интересам.',
      timeLabel: '3 часа назад',
      isRead: true,
      route: '/discovery',
    ),
    AppNotification(
      id: 'new-like-minded-people',
      kind: AppNotificationKind.social,
      title: 'Появились новые единомышленники',
      description: 'В подборке есть люди с похожими увлечениями.',
      timeLabel: '6 часов назад',
      isRead: true,
      route: '/discovery',
    ),
    AppNotification(
      id: 'mix-planet-update',
      kind: AppNotificationKind.update,
      title: 'Планета «Микс» ждёт тебя',
      description: 'Здесь делятся историями на самые разные темы.',
      timeLabel: 'Вчера',
      isRead: true,
      route: '/main/planet/p_other',
    ),
  ];
}
