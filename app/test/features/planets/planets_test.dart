import 'dart:math' as math;

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/map_spot.dart';
import 'package:dreem_world/data/models/planet.dart';
import 'package:dreem_world/data/models/planet_news.dart';
import 'package:dreem_world/data/providers/planet_providers.dart';
import 'package:dreem_world/data/repositories/mock_news_repository.dart';
import 'package:dreem_world/data/repositories/mock_planet_repository.dart';
import 'package:dreem_world/features/planets/cosmos/orbital_catalog.dart';
import 'package:dreem_world/features/planets/cosmos/realistic_planet.dart';
import 'package:dreem_world/features/planets/cosmos/realistic_sun.dart';
import 'package:dreem_world/features/planets/home/widgets/galactic_home_system.dart';
import 'package:dreem_world/features/planets/home/planet_home_screen.dart';

import 'package:dreem_world/features/planets/map/planet_map_screen.dart';
import 'package:dreem_world/features/planets/news/planet_news_screen.dart';
import 'package:dreem_world/features/planets/news/widgets/news_card.dart';
import 'package:dreem_world/features/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Планеты', () {
    test('каталог планет не пуст и содержит ключевые сообщества', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final List<String> ids = container
          .read(planetsProvider)
          .map((dynamic planet) => planet.id as String)
          .toList();

      expect(ids, isNotEmpty);
      expect(ids.length, 21);
      expect(ids, contains('p_fishing'));
      expect(ids, contains('p_travel'));
      expect(ids, contains('p_cinema'));
      expect(ids, contains('p_reading'));
      expect(ids, isNot(contains('p_books')));
      expect(ids, contains('p_collecting'));
      expect(
        container.read(planetByIdProvider('p_other'))?.name,
        'Планета «Микс»',
      );
    });

    testWidgets('главный экран отображает планеты', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const Scaffold(body: SizedBox()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('в шапке есть уведомления и настройки', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const Scaffold(body: PlanetHomeScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byTooltip('Уведомления'), findsOneWidget);
      expect(find.byTooltip('Настройки'), findsOneWidget);
      expect(find.text('Исследовать мир'), findsNothing);
    });

    testWidgets('нижние карточки можно закрыть крестиками', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const Scaffold(body: PlanetHomeScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      for (final String title in <String>[
        '21 планета — тысячи историй',
        'Популярные планеты',
        'Новые люди',
      ]) {
        final Finder closeButton = find.byTooltip('Закрыть: $title');
        expect(closeButton, findsOneWidget);
        await tester.tap(closeButton);
        await tester.pump();
        expect(find.text(title), findsNothing);
      }
    });

    testWidgets('окошко поиска по интересам закрывается крестиком', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const Scaffold(body: PlanetHomeScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      const String tooltip = 'Закрыть: Найди своих по интересам';
      expect(find.byTooltip(tooltip), findsOneWidget);
      expect(find.text('Найди своих по интересам'), findsOneWidget);

      await tester.tap(find.byTooltip(tooltip));
      await tester.pump();

      expect(find.byTooltip(tooltip), findsNothing);
      expect(find.text('Найди своих по интересам'), findsNothing);
    });

    testWidgets('кнопки шапки остаются видимыми на телефоне', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const Scaffold(body: PlanetHomeScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byTooltip('Уведомления'), findsOneWidget);
      expect(find.byTooltip('Настройки'), findsOneWidget);
    });
  });

  testWidgets('экран уведомлений показывает события разных типов', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const NotificationsScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Новое в планете «Кино»'), findsOneWidget);
    expect(find.text('Скоро событие: прогулка выходного дня'), findsOneWidget);
    expect(find.text('Подобрали новые миры для тебя'), findsOneWidget);
    expect(find.text('Исследовать мир'), findsNothing);
    expect(find.text('3 новых уведомления'), findsOneWidget);

    await tester.tap(find.text('Прочитать все'));
    await tester.pump();
    expect(find.text('Ты всё посмотрел'), findsOneWidget);
  });

  group('Карта планеты', () {
    test('для планеты генерируются отметки с координатами и тегами', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final Planet planet = container.read(planetByIdProvider('p_fishing'))!;
      final List<MapSpot> spots = container.read(
        planetMapSpotsProvider('p_fishing'),
      );

      expect(spots.length, greaterThanOrEqualTo(6));
      for (final MapSpot spot in spots) {
        expect(spot.x, inInclusiveRange(0, 1));
        expect(spot.y, inInclusiveRange(0, 1));
        expect(spot.tags, isNotEmpty);
        expect(spot.title, isNotEmpty);
      }
      // Отметки привязаны к интересам планеты.
      expect(
        spots.any((MapSpot spot) => spot.tags.any(planet.keywords.contains)),
        isTrue,
      );
    });

    testWidgets('экран карты показывает отметки и теги', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetMapScreen(planetId: 'p_fishing'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('отметок участников'), findsOneWidget);
      expect(find.textContaining('Отметить место'), findsOneWidget);
    });
  });

  group('Новости планеты', () {
    test('лента не пуста и обновляется при смене часа', () {
      const MockNewsRepository repo = MockNewsRepository();
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final Planet planet = container.read(planetByIdProvider('p_fishing'))!;

      final DateTime h1 = DateTime(2026, 1, 1, 10, 5);
      final DateTime h2 = DateTime(2026, 1, 1, 11, 5);

      final List<PlanetNewsItem> a = repo.newsFor(planet, now: h1);
      final List<PlanetNewsItem> b = repo.newsFor(planet, now: h1);
      final List<PlanetNewsItem> c = repo.newsFor(planet, now: h2);

      expect(a, isNotEmpty);
      // В течение одного часа лента стабильна.
      expect(
        a.map((PlanetNewsItem n) => n.id),
        equals(b.map((PlanetNewsItem n) => n.id)),
      );
      // В новый час — другая лента.
      expect(
        a.map((PlanetNewsItem n) => n.id),
        isNot(equals(c.map((PlanetNewsItem n) => n.id))),
      );
      expect(a.first.tag, planet.keywords.first);
    });

    testWidgets('экран новостей показывает ленту', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const PlanetNewsScreen(planetId: 'p_fishing'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('обновляется каждый час'), findsOneWidget);
      expect(find.byType(NewsCard), findsWidgets);
    });
  });

  group('Орбитальный каталог', () {
    testWidgets('каталог рисует солнце и планеты вокруг него', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final List<Planet> planets = const MockPlanetRepository().getPlanets();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: Scaffold(
            body: OrbitalCatalog(
              planets: planets,
              onPlanetTap: (Planet planet) {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(RealisticSun), findsOneWidget);
      expect(find.byType(RealisticPlanet), findsWidgets);
    });

    testWidgets('каждая планета обёрнута в обработчик нажатия', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final List<Planet> planets = const MockPlanetRepository().getPlanets();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: Scaffold(
            body: OrbitalCatalog(
              planets: planets,
              onPlanetTap: (Planet planet) {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.byType(GestureDetector),
        findsAtLeastNWidgets(planets.length),
      );
    });

    testWidgets('планеты не выходят за пределы области каталога', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final List<Planet> planets = const MockPlanetRepository().getPlanets();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: Scaffold(
            body: OrbitalCatalog(
              planets: planets,
              onPlanetTap: (Planet planet) {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final Rect catalog = tester.getRect(find.byType(OrbitalCatalog));

      for (final Element element in find.byType(RealisticPlanet).evaluate()) {
        final Rect r = tester.getRect(find.byWidget(element.widget));
        expect(
          r.top >= catalog.top - 0.5 && r.bottom <= catalog.bottom + 0.5,
          isTrue,
          reason: 'Планета выходит за границы по вертикали: $r vs $catalog',
        );
        expect(
          r.left >= catalog.left - 0.5 && r.right <= catalog.right + 0.5,
          isTrue,
          reason: 'Планета выходит за границы по горизонтали: $r vs $catalog',
        );
      }
    });
  });

  for (final Size viewport in <Size>[
    const Size(1920, 795),
    const Size(390, 844),
  ]) {
    testWidgets(
      'узлы галактики не пересекаются при размере ${viewport.width}x${viewport.height}',
      (WidgetTester tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final List<Planet> planets = const MockPlanetRepository().getPlanets();
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: Scaffold(
              body: GalacticHomeSystem(
                planets: planets,
                bottomReservedSpace: viewport.height < 800
                    ? 132
                    : viewport.width < 350
                    ? 0
                    : viewport.width < 700
                    ? 132
                    : 230,
                onPlanetTap: (Planet planet) {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));

        final List<Rect> nodes = <Rect>[
          for (final Planet planet in planets.take(21))
            tester.getRect(
              find.byKey(ValueKey<String>('galaxy-planet-${planet.id}')),
            ),
        ];
        final List<Rect> labels = <Rect>[
          for (final Planet planet in planets.take(21))
            tester.getRect(
              find.byKey(ValueKey<String>('galaxy-label-${planet.id}')),
            ),
        ];
        final List<Rect> planetPaintBounds = <Rect>[
          for (final Planet planet in planets.take(21))
            tester.getRect(
              find.descendant(
                of: find.byKey(ValueKey<String>('galaxy-planet-${planet.id}')),
                matching: find.byType(RealisticPlanet),
              ),
            ),
        ];
        final Rect scene = tester.getRect(find.byType(GalacticHomeSystem));
        final double sunSize =
            (math.min(viewport.width, viewport.height) * 0.19).clamp(
              112.0,
              190.0,
            );
        final Rect sunExclusion = Rect.fromCenter(
          center: Offset(
            scene.left + viewport.width / 2,
            scene.top +
                (viewport.height -
                        (viewport.height < 800
                            ? 132
                            : viewport.width < 350
                            ? 0
                            : viewport.width < 700
                            ? 132
                            : 230)) /
                    2,
          ),
          width: sunSize * 1.9,
          height: sunSize * 1.9,
        ).inflate(12);

        if (viewport.width >= 1200) {
          final Rect cars = tester.getRect(
            find.byKey(const ValueKey<String>('galaxy-planet-p_cars')),
          );
          expect(
            cars.center.dx,
            greaterThan(sunExclusion.center.dx),
            reason: 'Планета автолюбителей должна быть справа от солнца',
          );
          expect(
            cars.center.dx,
            lessThan(scene.center.dx + sunSize * 3.5),
            reason:
                'Планета автолюбителей должна остаться во внутренней орбите',
          );
        }

        expect(nodes, hasLength(planets.take(21).length));
        for (int index = 0; index < nodes.length; index++) {
          expect(
            scene.contains(nodes[index].topLeft) &&
                scene.contains(nodes[index].bottomRight),
            isTrue,
            reason: 'Узел галактики выходит за сцену: ${nodes[index]} / $scene',
          );
          expect(
            nodes[index].overlaps(sunExclusion),
            isFalse,
            reason:
                'Планета попала в зону солнца: ${nodes[index]} / $sunExclusion',
          );
          for (int other = index + 1; other < nodes.length; other++) {
            expect(
              nodes[index].overlaps(nodes[other]),
              isFalse,
              reason:
                  'Узлы галактики пересекаются: ${nodes[index]} / ${nodes[other]}',
            );
            expect(
              labels[index].overlaps(labels[other]),
              isFalse,
              reason:
                  'Подписи планет пересекаются: ${labels[index]} / ${labels[other]}',
            );
            expect(
              planetPaintBounds[index].overlaps(planetPaintBounds[other]),
              isFalse,
              reason:
                  'Изображения планет пересекаются: ${planetPaintBounds[index]} / ${planetPaintBounds[other]}',
            );
            expect(
              labels[index].overlaps(planetPaintBounds[other]),
              isFalse,
              reason:
                  'Подпись перекрывает соседнюю планету: ${labels[index]} / ${planetPaintBounds[other]}',
            );
          }
        }
      },
    );
  }
}
