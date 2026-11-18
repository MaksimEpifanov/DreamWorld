import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/planet.dart';
import 'package:dreem_world/data/models/planet_event.dart';
import 'package:dreem_world/data/providers/planet_providers.dart';
import 'package:dreem_world/data/repositories/mock_planet_event_repository.dart';
import 'package:dreem_world/data/repositories/mock_planet_repository.dart';
import 'package:dreem_world/features/planets/events/planet_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('События планеты', () {
    test('мок-репозиторий: заявка, подтверждение и отклонение', () async {
      final MockPlanetEventRepository repository = MockPlanetEventRepository(
        currentUserId: 'u1',
      );
      addTearDown(repository.dispose);

      final Planet planet = const MockPlanetRepository().byId('p_animals')!;
      final List<PlanetEvent> initial = await repository
          .watchEvents(planet)
          .first;
      expect(initial, isNotEmpty);

      final String eventId = initial.first.id;
      await repository.apply(planet, eventId);

      PlanetEvent current = (await repository.watchEvents(planet).first)
          .firstWhere((PlanetEvent event) => event.id == eventId);
      expect(current.hasApplied('u1'), isTrue);

      await repository.approve(planet, eventId, 'u1');
      current = (await repository.watchEvents(planet).first).firstWhere(
        (PlanetEvent event) => event.id == eventId,
      );
      expect(current.isParticipant('u1'), isTrue);
      expect(current.hasApplied('u1'), isFalse);

      await repository.decline(planet, eventId, 'u1');
      current = (await repository.watchEvents(planet).first).firstWhere(
        (PlanetEvent event) => event.id == eventId,
      );
      expect(current.isParticipant('u1'), isFalse);
    });

    testWidgets('экран событий показывает создание и список', (
      WidgetTester tester,
    ) async {
      final MockPlanetEventRepository repository = MockPlanetEventRepository(
        currentUserId: 'u1',
      );
      addTearDown(repository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            planetEventRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetEventsScreen(planetId: 'p_animals'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Создать событие'), findsOneWidget);
      expect(find.textContaining('Совместная встреча'), findsOneWidget);
    });
  });
}
