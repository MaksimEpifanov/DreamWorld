import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';
import '../models/conversation.dart';
import '../models/planet_event.dart';
import '../models/profile.dart';
import '../repositories/mock_notification_repository.dart';
import '../repositories/notification_repository.dart';
import '../services/firebase_bootstrap.dart';
import 'app_providers.dart';
import 'planet_providers.dart';

/// Репозиторий демонстрационных уведомлений (только мок-режим без Firebase).
final Provider<NotificationRepository> notificationRepositoryProvider =
    Provider<NotificationRepository>(
      (Ref ref) => const MockNotificationRepository(),
    );

/// Просмотренные уведомления (идентификаторы), сохраняются локально.
///
/// Нужны, чтобы «новые» события планет не висели непрочитанными вечно: после
/// просмотра событие помечается прочитанным и остаётся в списке, но без метки.
final StateNotifierProvider<SeenNotificationsController, Set<String>>
seenNotificationsProvider =
    StateNotifierProvider<SeenNotificationsController, Set<String>>(
      (Ref ref) => SeenNotificationsController(ref),
    );

class SeenNotificationsController extends StateNotifier<Set<String>> {
  SeenNotificationsController(this._ref) : super(<String>{}) {
    _load();
  }

  final Ref _ref;

  String get _key => 'seen_notifications_${_ref.read(currentUserIdProvider)}';

  Future<void> _load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? stored = prefs.getStringList(_key);
      if (stored == null || stored.isEmpty || !mounted) return;
      state = <String>{...state, ...stored};
    } catch (_) {
      // Локальное хранилище недоступно — считаем, что ещё ничего не смотрели.
    }
  }

  Future<void> _persist() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, state.toList(growable: false));
    } catch (_) {
      // Не критично: при следующем запуске уведомления снова станут «новыми».
    }
  }

  /// Помечает одно уведомление просмотренным.
  void markSeen(String id) {
    if (id.isEmpty || state.contains(id)) return;
    state = <String>{...state, id};
    _persist();
  }

  /// Помечает просмотренными сразу несколько уведомлений.
  void markAllSeen(Iterable<String> ids) {
    final Set<String> next = <String>{...state, ...ids};
    if (next.length == state.length) return;
    state = next;
    _persist();
  }
}

/// Последние события всех планет — источник уведомлений «кто-то зовёт».
final StreamProvider<List<PlanetEvent>> recentEventsProvider =
    StreamProvider<List<PlanetEvent>>((Ref ref) {
      return ref
          .watch(planetEventRepositoryProvider)
          .watchRecentEvents(limit: 20);
    });

/// Живой список уведомлений.
///
/// В рабочей версии собирается из реальных данных: заявки в контакты
/// показываются отдельно на экране, а здесь — новые сообщения и события
/// планет (кто-то предлагает поехать или пойти). В мок-режиме — демо-лента.
final Provider<List<AppNotification>>
notificationsProvider = Provider<List<AppNotification>>((Ref ref) {
  final Set<String> seen = ref.watch(seenNotificationsProvider);
  final List<AppNotification> demo = ref
      .watch(notificationRepositoryProvider)
      .getNotifications()
      .map(
        (AppNotification item) => item.isRead || seen.contains(item.id)
            ? item.copyWith(isRead: true)
            : item,
      )
      .toList(growable: false);

  if (!isFirebaseInitialized) {
    return demo;
  }

  final String me = ref.watch(currentUserIdProvider);
  final List<Profile> profiles =
      ref.watch(communityProfilesProvider).valueOrNull ?? const <Profile>[];
  final Map<String, String> names = <String, String>{
    for (final Profile profile in profiles)
      if (profile.name.trim().isNotEmpty) profile.id: profile.name.trim(),
  };

  final List<(DateTime, AppNotification)> entries =
      <(DateTime, AppNotification)>[
        for (final AppNotification item in demo)
          (DateTime.fromMillisecondsSinceEpoch(0), item),
      ];

  // События планет: не свои и не прошедшие.
  final DateTime now = DateTime.now();
  final List<PlanetEvent> events =
      ref.watch(recentEventsProvider).valueOrNull ?? const <PlanetEvent>[];
  for (final PlanetEvent event in events) {
    if (event.authorId == me) continue;
    final DateTime? date = event.dateValue;
    if (date != null && date.isBefore(DateTime(now.year, now.month, now.day))) {
      continue;
    }
    final String id = 'event:${event.id}';
    entries.add((
      event.createdAtValue ?? DateTime.fromMillisecondsSinceEpoch(0),
      AppNotification(
        id: id,
        kind: AppNotificationKind.event,
        title: event.title.isEmpty ? 'Новое событие' : event.title,
        description: _eventDescription(event, names[event.authorId]),
        timeLabel: relativeTimeLabel(event.createdAtValue),
        isRead: seen.contains(id),
        route: '/main/planet/${event.planetId}/events',
      ),
    ));
  }

  // Новые сообщения: одно уведомление на диалог с непрочитанными.
  final List<Conversation> conversations =
      ref.watch(conversationsProvider).valueOrNull ?? const <Conversation>[];
  for (final Conversation conversation in conversations) {
    if (!conversation.hasUnread) continue;
    final String other = conversation.otherParticipantId(me);
    final String name = names[other] ?? 'Пользователь';
    final String text = conversation.lastMessage?.displayText ?? '';
    entries.add((
      conversation.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      AppNotification(
        id: 'chat:${conversation.id}',
        kind: AppNotificationKind.social,
        title: 'Новое сообщение',
        description: text.isEmpty ? 'От $name' : '$name: $text',
        timeLabel: relativeTimeLabel(conversation.updatedAt),
        isRead: false,
        route: '/chat/${conversation.id}',
      ),
    ));
  }

  entries.sort(
    ((DateTime, AppNotification) a, (DateTime, AppNotification) b) =>
        b.$1.compareTo(a.$1),
  );
  return List<AppNotification>.unmodifiable(
    entries.map(((DateTime, AppNotification) entry) => entry.$2),
  );
});

/// Сколько уведомлений ждёт внимания: заявки в контакты, новые сообщения и
/// события. Используется для счётчика на иконке в шапке.
final Provider<int> notificationsUnreadCountProvider = Provider<int>((Ref ref) {
  final int requests =
      ref
          .watch(currentProfileProvider)
          .valueOrNull
          ?.incomingContactRequestIds
          .length ??
      0;
  final int unread = ref
      .watch(notificationsProvider)
      .where((AppNotification item) => !item.isRead)
      .length;
  return requests + unread;
});

/// Действия над уведомлениями.
final Provider<NotificationsController> notificationsControllerProvider =
    Provider<NotificationsController>(
      (Ref ref) => NotificationsController(ref),
    );

class NotificationsController {
  NotificationsController(this._ref);

  final Ref _ref;

  /// Помечает уведомление прочитанным. Для сообщений помечает диалог
  /// прочитанным в чате, для событий — сохраняет отметку локально.
  Future<void> markRead(String id) async {
    if (id.startsWith('chat:')) {
      final String conversationId = id.substring('chat:'.length);
      try {
        await _ref.read(chatRepositoryProvider).markAsRead(conversationId);
      } catch (_) {
        // Чат недоступен — уведомление останется, попробуем в следующий раз.
      }
      return;
    }
    _ref.read(seenNotificationsProvider.notifier).markSeen(id);
  }

  /// Помечает прочитанными все уведомления.
  Future<void> markAllRead() async {
    final List<AppNotification> items = _ref.read(notificationsProvider);
    _ref
        .read(seenNotificationsProvider.notifier)
        .markAllSeen(
          items
              .where((AppNotification item) => !item.id.startsWith('chat:'))
              .map((AppNotification item) => item.id),
        );
    for (final AppNotification item in items) {
      if (!item.id.startsWith('chat:')) continue;
      try {
        await _ref
            .read(chatRepositoryProvider)
            .markAsRead(item.id.substring('chat:'.length));
      } catch (_) {
        // Пропускаем недоступный диалог.
      }
    }
  }
}

/// Описание события для уведомления: кто зовёт и куда.
String _eventDescription(PlanetEvent event, String? authorName) {
  final String author = (authorName ?? event.authorName).trim();
  final List<String> parts = <String>[
    if (author.isNotEmpty) '$author предлагает',
    if (event.date.isNotEmpty) _shortDate(event.date),
    if (event.place.isNotEmpty) event.place,
  ];
  if (parts.isEmpty) return 'Кто-то предлагает собраться';
  return parts.join(' · ');
}

String _shortDate(String iso) {
  final DateTime? date = DateTime.tryParse(iso);
  if (date == null) return iso;
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year}';
}

/// Человекопонятная подпись времени («5 минут назад», «Вчера»).
String relativeTimeLabel(DateTime? time) {
  if (time == null) return '';
  final DateTime now = DateTime.now();
  final Duration diff = now.difference(time);
  if (diff.isNegative || diff.inMinutes < 1) return 'только что';
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} ${_plural(diff.inMinutes, 'минуту', 'минуты', 'минут')} назад';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} ${_plural(diff.inHours, 'час', 'часа', 'часов')} назад';
  }
  if (diff.inDays == 1) return 'вчера';
  if (diff.inDays < 7) {
    return '${diff.inDays} ${_plural(diff.inDays, 'день', 'дня', 'дней')} назад';
  }
  return _shortDate(time.toIso8601String());
}

String _plural(int count, String one, String few, String many) {
  final int mod10 = count % 10;
  final int mod100 = count % 100;
  if (mod10 == 1 && mod100 != 11) return one;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
  return many;
}
