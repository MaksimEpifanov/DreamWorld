import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/map_spot.dart';
import 'package:dreem_world/data/models/planet.dart';
import 'package:dreem_world/data/repositories/mock_map_repository.dart';
import 'package:dreem_world/data/repositories/mock_planet_repository.dart';
import 'package:dreem_world/data/repositories/mock_spot_report_repository.dart';
import 'package:dreem_world/features/planets/map/planet_map_screen.dart';
import 'package:dreem_world/features/planets/map/widgets/spot_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MapSpot _spot(String id, String authorId) => MapSpot(
  id: id,
  title: 'Тестовая точка',
  description: 'Описание',
  authorName: 'Автор',
  emoji: '📍',
  tags: const <String>[],
  likes: 0,
  x: 0.5,
  y: 0.5,
  authorId: authorId,
);

void main() {
  group('Видимость отметок на карте', () {
    test('скрывает заметки заблокированных авторов', () {
      final List<MapSpot> spots = <MapSpot>[
        _spot('1', 'good'),
        _spot('2', 'bad'),
        _spot('3', ''),
      ];
      final List<MapSpot> visible = visibleMapSpots(spots, <String>{'bad'});
      expect(visible.map((MapSpot s) => s.id), <String>['1', '3']);
    });

    test('без блокировок показывает все отметки', () {
      final List<MapSpot> spots = <MapSpot>[_spot('1', 'a'), _spot('2', 'b')];
      expect(visibleMapSpots(spots, const <String>{}), hasLength(2));
    });
  });

  testWidgets('в шторке отметки есть кнопка жалобы', (
    WidgetTester tester,
  ) async {
    final Planet planet = const MockPlanetRepository().getPlanets().first;
    bool reported = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.of(AppThemeName.neonViolet),
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showSpotSheet(
                  context,
                  spot: _spot('1', 'other'),
                  planet: planet,
                  liked: false,
                  authorName: 'Я',
                  authorId: 'me',
                  onCommentAdded: (MapComment _) {},
                  onLikeToggled: (bool _) {},
                  onReport: () => reported = true,
                ),
                child: const Text('Открыть'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Пожаловаться'), findsOneWidget);
    await tester.tap(find.byTooltip('Пожаловаться'));
    expect(reported, isTrue);
  });

  group('Счётчик жалоб на автора заметок', () {
    test('один пользователь учитывается один раз', () async {
      final MockSpotReportRepository repository = MockSpotReportRepository(
        currentUserId: 'u1',
      );
      expect(
        await repository.registerReport(authorId: 'bad', authorName: 'Плохой'),
        1,
      );
      expect(
        await repository.registerReport(authorId: 'bad', authorName: 'Плохой'),
        1,
      );
    });

    test('разные пользователи делят общий счётчик', () async {
      final Map<String, Set<String>> store = <String, Set<String>>{};
      int count = 0;
      for (final String userId in <String>['u1', 'u2', 'u3', 'u4']) {
        count = await MockSpotReportRepository(
          currentUserId: userId,
          store: store,
        ).registerReport(authorId: 'bad', authorName: 'Плохой');
      }
      expect(count, 4);
    });

    test('порог: заметки убираются у всех только при более 3 жалоб', () {
      expect(shouldRemoveSpotsForEveryone(0), isFalse);
      expect(shouldRemoveSpotsForEveryone(3), isFalse);
      expect(shouldRemoveSpotsForEveryone(4), isTrue);
    });
  });

  group('Удаление заметок автора у всех', () {
    test('deleteSpotsByAuthor убирает только заметки нарушителя', () async {
      final Planet planet = const MockPlanetRepository().getPlanets().first;
      final MockMapRepository repository = MockMapRepository(
        currentUserId: 'me',
      );
      addTearDown(repository.dispose);

      await repository.addSpot(planet, _spot('mine', 'me'));
      await repository.addSpot(planet, _spot('bad1', 'bad'));
      await repository.addSpot(planet, _spot('bad2', 'bad'));

      final int removed = await repository.deleteSpotsByAuthor(planet, 'bad');
      expect(removed, 2);

      final List<MapSpot> spots = await repository.watchSpots(planet).first;
      expect(spots.any((MapSpot s) => s.authorId == 'bad'), isFalse);
      expect(spots.any((MapSpot s) => s.id == 'mine'), isTrue);
    });

    test('deleteSpotsByAuthor с пустым автором ничего не удаляет', () async {
      final Planet planet = const MockPlanetRepository().getPlanets().first;
      final MockMapRepository repository = MockMapRepository();
      addTearDown(repository.dispose);
      expect(await repository.deleteSpotsByAuthor(planet, ''), 0);
    });
  });
}
