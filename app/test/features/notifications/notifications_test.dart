import 'package:dreem_world/data/models/app_notification.dart';
import 'package:dreem_world/data/models/planet.dart';
import 'package:dreem_world/data/models/planet_event.dart';
import 'package:dreem_world/data/providers/notification_providers.dart';
import 'package:dreem_world/data/repositories/mock_planet_event_repository.dart';
import 'package:dreem_world/data/repositories/mock_planet_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Подпись времени уведомлений', () {
    test('человекопонятные интервалы', () {
      final DateTime now = DateTime.now();
      expect(relativeTimeLabel(null), '');
      expect(relativeTimeLabel(now), 'только что');
      expect(
        relativeTimeLabel(now.subtract(const Duration(minutes: 5))),
        '5 минут назад',
      );
      expect(
        relativeTimeLabel(now.subtract(const Duration(hours: 2))),
        '2 часа назад',
      );
      expect(
        relativeTimeLabel(now.subtract(const Duration(days: 1, hours: 1))),
        'вчера',
      );
      expect(
        relativeTimeLabel(now.subtract(const Duration(days: 3))),
        '3 дня назад',
      );
    });
  });

  group('Сводка событий всех планет', () {
    test('watchRecentEvents собирает события из каталога планет', () async {
      final List<Planet> planets = const MockPlanetRepository().getPlanets();
      final MockPlanetEventRepository repository = MockPlanetEventRepository(
        currentUserId: 'u1',
        planets: planets,
      );
      addTearDown(repository.dispose);

      final List<PlanetEvent> events = await repository
          .watchRecentEvents()
          .first;

      expect(events, isNotEmpty);
      // Свежие события идут первыми.
      for (int i = 1; i < events.length; i++) {
        final DateTime? previous = events[i - 1].createdAtValue;
        final DateTime? current = events[i].createdAtValue;
        expect(previous == null || current == null || !previous.isBefore(current), isTrue);
      }
    });
  });

  group('Уведомления', () {
    test('в мок-режиме показывается демо-лента и счётчик', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final List<AppNotification> items = container.read(notificationsProvider);
      expect(items.length, 6);
      expect(items.where((AppNotification item) => !item.isRead).length, 3);
      expect(container.read(notificationsUnreadCountProvider), 3);
    });

    test('просмотренные уведомления помечаются прочитанными', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final List<AppNotification> items = container.read(notificationsProvider);
      final String id = items.first.id;

      container.read(seenNotificationsProvider.notifier).markSeen(id);
      final List<AppNotification> after = container.read(notificationsProvider);
      expect(after.firstWhere((AppNotification item) => item.id == id).isRead, isTrue);
    });
  });
}
