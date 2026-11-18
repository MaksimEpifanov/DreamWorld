import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/map_spot.dart';
import 'package:dreem_world/data/models/planet.dart';
import 'package:dreem_world/data/repositories/mock_planet_repository.dart';
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
}
