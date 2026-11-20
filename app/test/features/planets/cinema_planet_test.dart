import 'dart:io';

import 'package:dreem_world/core/constants/planet_genre_visuals.dart';
import 'package:dreem_world/core/constants/planet_interest_details.dart';
import 'package:dreem_world/core/constants/planet_scene_theme.dart';
import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/planet.dart';
import 'package:dreem_world/data/models/planet_news.dart';
import 'package:dreem_world/data/providers/planet_interest_selection_provider.dart';
import 'package:dreem_world/data/providers/planet_providers.dart';
import 'package:dreem_world/data/repositories/mock_planet_repository.dart';
import 'package:dreem_world/data/repositories/planet_repository.dart';
import 'package:dreem_world/features/planets/detail/planet_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _LegacyPlanetRepository implements PlanetRepository {
  const _LegacyPlanetRepository(this.planet);

  final Planet planet;

  @override
  List<Planet> getPlanets() => <Planet>[planet];

  @override
  Planet? byId(String id) => id == planet.id ? planet : null;
}

class _RouteStub extends StatelessWidget {
  const _RouteStub(this.marker);

  final String marker;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text('МАРКЕР:$marker'));
}

GoRouter _router(String planetId) => GoRouter(
  initialLocation: '/main/planet/$planetId',
  routes: <RouteBase>[
    GoRoute(
      path: '/main',
      builder: (BuildContext context, GoRouterState state) =>
          const _RouteStub('main'),
    ),
    GoRoute(
      path: '/main/planet/:id',
      builder: (BuildContext context, GoRouterState state) =>
          PlanetDetailScreen(planetId: state.pathParameters['id'] ?? ''),
      routes: <RouteBase>[
        GoRoute(
          path: 'map',
          builder: (BuildContext context, GoRouterState state) =>
              const _RouteStub('map'),
        ),
        GoRoute(
          path: 'chat',
          builder: (BuildContext context, GoRouterState state) =>
              const _RouteStub('chat'),
        ),
        GoRoute(
          path: 'events',
          builder: (BuildContext context, GoRouterState state) =>
              const _RouteStub('events'),
        ),
        GoRoute(
          path: 'news',
          builder: (BuildContext context, GoRouterState state) =>
              const _RouteStub('news'),
        ),
      ],
    ),
    GoRoute(
      path: '/discovery',
      builder: (BuildContext context, GoRouterState state) =>
          const _RouteStub('discovery'),
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (BuildContext context, GoRouterState state) =>
          const _RouteStub('personal-chat'),
    ),
  ],
);

ProviderContainer _testContainer() {
  final List<PlanetNewsItem> news = <PlanetNewsItem>[
    PlanetNewsItem(
      id: 'test_news_1',
      title: 'Премьеры и что смотреть вечером',
      summary: 'ИИ подобрал фильмы по вкусам участников планеты.',
      emoji: '🍿',
      sourceName: 'ИИ-редакция Dreem',
      tag: 'Кино',
      publishedAt: DateTime(2026, 11, 19, 12),
      likes: 42,
    ),
  ];
  return ProviderContainer(
    overrides: <Override>[
      for (final Planet planet in MockPlanetRepository.planets)
        planetNewsProvider(planet.id).overrideWith(
          (Ref ref) => Stream<List<PlanetNewsItem>>.value(news),
        ),
    ],
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final File font = File('test/fonts/Roboto-Regular.ttf');
    if (!font.existsSync()) return;
    final FontLoader loader = FontLoader('Roboto')
      ..addFont(
        Future<ByteData>.value(ByteData.view(font.readAsBytesSync().buffer)),
      );
    await loader.load();
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    ProviderContainer container, {
    String planetId = 'p_cinema',
    Size size = const Size(1400, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.of(AppThemeName.neonViolet),
          routerConfig: _router(planetId),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    while (tester.takeException() != null) {}
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('экран Кино показывает шапку, вкладки и все восемь жанров', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _testContainer();
    addTearDown(container.dispose);
    await pumpScreen(tester, container);

    expect(find.text('Кино'), findsWidgets);
    expect(find.text('Фильмы, сериалы и громкие премьеры'), findsOneWidget);
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Жанры'), findsOneWidget);
    expect(find.text('Новости'), findsOneWidget);
    expect(find.text('Люди'), findsOneWidget);
    expect(find.text('События'), findsOneWidget);
    expect(find.text('Карта'), findsOneWidget);
    expect(find.text('Чат'), findsOneWidget);
    expect(find.text('Разделы'), findsOneWidget);
    expect(find.text('Жанры и форматы'), findsOneWidget);
    expect(find.text('Рекомендуемые люди'), findsOneWidget);
    expect(find.text('Все →'), findsOneWidget);
    expect(find.text('Смотреть всех в подборе'), findsOneWidget);
    expect(
      find.text('Делись впечатлениями, находи компанию для кино!'),
      findsOneWidget,
    );
    expect(
      find.text('Рассказывай о фильмах и собирай киновечера'),
      findsOneWidget,
    );

    for (final String label in <String>[
      'Фантастика',
      'Триллеры',
      'Комедии',
      'Артхаус',
      'Аниме',
      'Документальные',
      'Классика',
      'Дорамы',
    ]) {
      expect(
        find.byKey(ValueKey<String>('cinema-genre-$label')),
        findsOneWidget,
        reason: 'не найдена карточка жанра $label',
      );
    }
  });

  testWidgets('тап по карточке жанра синхронен с чек-листом', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _testContainer();
    addTearDown(container.dispose);
    await pumpScreen(tester, container);

    const String item = 'Аниме и анимация (для взрослых и семейное)';
    expect(
      container.read(selectedPlanetInterestsProvider('p_cinema')),
      isEmpty,
    );

    await tapVisible(
      tester,
      find.byKey(const ValueKey<String>('cinema-genre-Аниме')),
    );
    expect(
      container.read(selectedPlanetInterestsProvider('p_cinema')),
      contains(item),
    );
    expect(find.text(item), findsOneWidget);

    await tapVisible(
      tester,
      find.byKey(ValueKey<String>('planet-interest-$item')),
    );
    expect(
      container.read(selectedPlanetInterestsProvider('p_cinema')),
      isEmpty,
    );
  });

  testWidgets('вкладки Карта и Чат открывают существующие маршруты', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _testContainer();
    addTearDown(container.dispose);
    await pumpScreen(tester, container);

    await tapVisible(
      tester,
      find.byKey(const ValueKey<String>('cinema-tab-Карта')),
    );
    expect(find.text('МАРКЕР:map'), findsOneWidget);

    await pumpScreen(tester, container);
    await tapVisible(
      tester,
      find.byKey(const ValueKey<String>('cinema-tab-Чат')),
    );
    expect(find.text('МАРКЕР:chat'), findsOneWidget);
  });

  testWidgets('нижний банер ведёт в события, чат и на карту', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _testContainer();
    addTearDown(container.dispose);
    await pumpScreen(tester, container);

    await tapVisible(tester, find.text('Создать событие'));
    expect(find.text('МАРКЕР:events'), findsOneWidget);

    await pumpScreen(tester, container);
    await tapVisible(tester, find.text('Чат сообщества'));
    expect(find.text('МАРКЕР:chat'), findsOneWidget);

    await pumpScreen(tester, container);
    await tapVisible(tester, find.text('Карта планеты'));
    expect(find.text('МАРКЕР:map'), findsOneWidget);
  });

  testWidgets('кнопка «Присоединиться» меняет состояние планеты', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _testContainer();
    addTearDown(container.dispose);
    await pumpScreen(tester, container);

    expect(find.text('Присоединиться'), findsOneWidget);
    await tapVisible(tester, find.text('Присоединиться'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Вы уже присоединились'), findsOneWidget);
    expect(find.text('Покинуть планету'), findsOneWidget);
  });

  testWidgets('герой-карточка показывает первую новость планеты', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _testContainer();
    addTearDown(container.dispose);
    await pumpScreen(tester, container);

    final news = container.read(planetNewsProvider('p_cinema')).valueOrNull;
    expect(news, isNotEmpty);
    expect(find.text('Фильм дня'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('cinema-featured-news')),
      findsOneWidget,
    );
    expect(find.text(news!.first.title), findsWidgets);
    expect(find.textContaining(news.first.sourceName), findsWidgets);
    expect(find.text('${news.first.likes}'), findsWidgets);

    await tapVisible(
      tester,
      find.byKey(const ValueKey<String>('cinema-featured-news')),
    );
    expect(find.text('МАРКЕР:news'), findsOneWidget);
  });

  testWidgets('рыбалка использует тематическую раскладку с надписью «Улов дня»', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _testContainer();
    addTearDown(container.dispose);
    await pumpScreen(tester, container, planetId: 'p_fishing');

    expect(find.text('Планета Рыбалки'), findsWidgets);
    expect(find.text('Направления'), findsWidgets);
    expect(find.text('Виды ловли и снасти'), findsOneWidget);
    expect(find.text('Улов дня'), findsOneWidget);
    expect(find.text('Фильм дня'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('cinema-genre-Аниме')),
      findsNothing,
    );
  });

  test('полные названия жанров совпадают с каталогом интересов Кино', () {
    final List<String> catalog = planetInterestDetailsByScene[PlanetScene.cinema]!
        .expand((PlanetInterestGroup group) => group.items)
        .toList();
    final List<PlanetGenreVisual> visuals =
        planetGenreVisualsByScene[PlanetScene.cinema]!;

    expect(visuals, hasLength(8));
    for (final PlanetGenreVisual visual in visuals) {
      expect(
        catalog,
        contains(visual.fullItem),
        reason: 'жанр «${visual.shortLabel}» не найден в каталоге интересов',
      );
    }
  });

  test('все оформленные планеты имеют обложку, визуалы и тему', () {
    final List<Planet> planets = MockPlanetRepository.planets;
    expect(planets, hasLength(21));

    for (final Planet planet in planets) {
      final String? coverPath = planetCoverByPlanetId[planet.id];
      expect(coverPath, isNotNull, reason: 'нет обложки у ${planet.id}');

      final List<PlanetGenreVisual>? visuals =
          planetGenreVisualsByScene[planet.scene];
      expect(visuals, isNotNull, reason: 'нет визуалов у ${planet.id}');
      expect(visuals, isNotEmpty, reason: 'пустые визуалы у ${planet.id}');

      final List<String> catalog =
          planetInterestDetailsByScene[planet.scene]!
              .expand((PlanetInterestGroup group) => group.items)
              .toList();
      final List<String> expectedCatalog =
          planet.id == 'p_reading'
              ? catalog.take(visuals!.length).toList()
              : catalog;
      expect(
        visuals!.map((PlanetGenreVisual visual) => visual.fullItem).toList(),
        expectedCatalog,
        reason: 'несовпадение каталога у ${planet.id}',
      );

      final List<String> labels =
          visuals
              .map((PlanetGenreVisual visual) => visual.shortLabel)
              .toList();
      expect(
        labels.toSet().length,
        labels.length,
        reason: 'дубли подписей у ${planet.id}',
      );

      if (planet.id == 'p_cinema') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/cinema/'),
            reason: 'карточка Кино должна использовать свой жанровый ассет',
          );
        }
      } else if (planet.id == 'p_reading') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_reading/'),
            reason: 'карточка Клуба чтения должна использовать локальный ассет',
          );
        }
        expect(
          labels,
          isNot(contains('Поэзия и драматургия')),
          reason: 'карточка «Поэзия и драматургия» не должна отображаться',
        );
        expect(
          visuals.last.assetPath,
          endsWith('/5.webp'),
          reason: 'карточка «Статьи» должна использовать пятый локальный файл',
        );
      } else if (planet.id == 'p_music') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_music/'),
            reason: 'карточка Музыки должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_food') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_food/'),
            reason: 'карточка Кулинаров должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_travel') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_travel/'),
            reason: 'карточка Путешествий должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_nature') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_nature/'),
            reason: 'карточка Природы должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_gaming') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_gaming/'),
            reason: 'карточка Геймеров должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_fishing') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_fishing/'),
            reason: 'карточка Рыбалки должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_cars') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_cars/'),
            reason: 'карточка Автолюбителей должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_esoteric') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_esoteric/'),
            reason: 'карточка Эзотерики должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_volunteering') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_volunteering/'),
            reason: 'карточка Планеты добра должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_psychology') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_psychology/'),
            reason: 'карточка Психологии должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_gardening') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_gardening/'),
            reason: 'карточка Садоводства должна использовать локальный ассет',
          );
        }
        expect(
          visuals[1].assetPath,
          endsWith('/2.jpg'),
          reason: 'второй файл садоводства — настоящий JPEG',
        );
      } else if (planet.id == 'p_sports') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_sports/'),
            reason: 'карточка Спорта должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_other') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_other/'),
            reason: 'карточка «Микс» должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_collecting') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_collecting/'),
            reason: 'карточка «Коллекционеров» должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_art') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_art/'),
            reason: 'карточка «Художников» должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_finance') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_finance/'),
            reason: 'карточка «Финансов» должна использовать локальный ассет',
          );
        }
        expect(
          visuals[5].assetPath,
          endsWith('/6.png'),
          reason: 'шестой файл финансов — настоящий PNG',
        );
      } else if (planet.id == 'p_selfdev') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_selfdev/'),
            reason: 'карточка «Саморазвития» должна использовать локальный ассет',
          );
        }
      } else if (planet.id == 'p_tech') {
        for (final PlanetGenreVisual visual in visuals) {
          expect(
            visual.assetPath,
            startsWith('assets/planets/genres/p_tech/'),
            reason: 'карточка «Технологий» должна использовать локальный ассет',
          );
        }
      } else {
        for (int i = 0; i < visuals.length; i++) {
          final String expectedPath =
              'assets/planets/genres/${planet.id}/${(i + 1).toString().padLeft(2, '0')}.jpg';
          expect(
            visuals[i].assetPath,
            expectedPath,
            reason: 'неверный путь карточки жанра у ${planet.id}',
          );
        }
      }

      final PlanetSceneTheme theme = themeForScene(planet.scene);
      expect(theme.genreAnchorLabel, isNotEmpty);
      expect(theme.genreSectionTitle, isNotEmpty);
      expect(theme.checklistTitle, isNotEmpty);
      expect(theme.featuredTitle, isNotEmpty);
      expect(theme.bannerHeadline, isNotEmpty);
      expect(theme.bannerSubtitle, isNotEmpty);
    }
  });

  test('тематические подписи планет отличаются от киношных', () {
    final PlanetSceneTheme cinemaTheme = themeForScene(PlanetScene.cinema);
    for (final Planet planet in MockPlanetRepository.planets) {
      if (planet.id == 'p_cinema') continue;
      final PlanetSceneTheme theme = themeForScene(planet.scene);
      expect(theme.featuredTitle, isNot(cinemaTheme.featuredTitle));
      expect(theme.bannerHeadline, isNot(cinemaTheme.bannerHeadline));
      expect(theme.bannerSubtitle, isNot(cinemaTheme.bannerSubtitle));
    }
  });

  for (final Planet planet in MockPlanetRepository.planets) {
    testWidgets('тематический экран планеты ${planet.id}', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = _testContainer();
      addTearDown(container.dispose);
      await pumpScreen(tester, container, planetId: planet.id);

      final PlanetSceneTheme theme = themeForScene(planet.scene);
      final List<PlanetGenreVisual> visuals =
          planetGenreVisualsByScene[planet.scene]!;

      expect(find.text(planet.shortName), findsWidgets);
      expect(find.text(theme.genreAnchorLabel), findsWidgets);
      expect(find.text(theme.genreSectionTitle), findsWidgets);
      expect(find.text(theme.checklistTitle), findsWidgets);
      expect(find.text(theme.featuredTitle), findsOneWidget);
      expect(find.text(theme.bannerHeadline), findsOneWidget);
      expect(find.text(theme.bannerSubtitle), findsOneWidget);
      expect(
        find.byKey(ValueKey<String>('cinema-featured-news')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          ValueKey<String>('cinema-genre-${visuals.first.shortLabel}'),
        ),
        findsOneWidget,
      );

      if (planet.id != 'p_cinema') {
        expect(find.text('Фильм дня'), findsNothing);
        expect(
          find.text('Делись впечатлениями, находи компанию для кино!'),
          findsNothing,
        );
      }
    });
  }

  testWidgets('планета без оформления остаётся на старом экране', (
    WidgetTester tester,
  ) async {
    final Planet legacyPlanet = Planet(
      id: 'p_legacy',
      name: 'Планета Тестовая',
      tagline: 'Пока без оформления',
      description: 'Проверка старого варианта экрана',
      emoji: '🪐',
      scene: PlanetScene.space,
      primary: const Color(0xFF4A3AFF),
      secondary: const Color(0xFF00C2FF),
      accent: const Color(0xFF9E8CFF),
      memberCount: 1,
      keywords: const <String>['тест'],
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        planetRepositoryProvider.overrideWithValue(
          _LegacyPlanetRepository(legacyPlanet),
        ),
        planetNewsProvider('p_legacy').overrideWith(
          (Ref ref) => Stream<List<PlanetNewsItem>>.value(
            <PlanetNewsItem>[],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await pumpScreen(tester, container, planetId: 'p_legacy');

    expect(find.text('Планета Тестовая'), findsWidgets);
    expect(find.text('Присоединиться'), findsOneWidget);
    expect(find.text('Смотреть всех в подборе'), findsOneWidget);
    expect(find.text('Разделы'), findsNothing);
    expect(find.text('Материал дня'), findsNothing);
  });

  for (final MapEntry<String, Size> viewport in const <String, Size>{
    'SE1': Size(320, 568),
    'android': Size(360, 640),
    'iphone14': Size(390, 844),
    'android landscape': Size(640, 360),
    'iphone14 landscape': Size(844, 390),
  }.entries) {
    testWidgets('p_cinema без переполнений: ${viewport.key}', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = _testContainer();
      addTearDown(container.dispose);

      final List<String> problems = <String>[];
      final void Function(FlutterErrorDetails)? previous = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        problems.add(details.toString());
      };
      try {
        await pumpScreen(
          tester,
          container,
          size: viewport.value,
        );
      } finally {
        FlutterError.onError = previous;
      }

      final List<String> overflow = problems
          .where((String details) => details.contains('overflowed by'))
          .toList();
      expect(
        overflow,
        isEmpty,
        reason: '${viewport.key}:\n${overflow.join('\n')}',
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final String planetId in <String>[
    'p_fishing',
    'p_music',
    'p_collecting',
  ]) {
    for (final MapEntry<String, Size> viewport in const <String, Size>{
      'SE1': Size(320, 568),
      'android': Size(360, 640),
      'iphone14 landscape': Size(844, 390),
    }.entries) {
      testWidgets('$planetId без переполнений: ${viewport.key}', (
        WidgetTester tester,
      ) async {
        final ProviderContainer container = _testContainer();
        addTearDown(container.dispose);

        final List<String> problems = <String>[];
        final void Function(FlutterErrorDetails)? previous = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          problems.add(details.toString());
        };
        try {
          await pumpScreen(tester, container, size: viewport.value, planetId: planetId);
        } finally {
          FlutterError.onError = previous;
        }

        final List<String> overflow = problems
            .where((String details) => details.contains('overflowed by'))
            .toList();
        expect(
          overflow,
          isEmpty,
          reason: '$planetId / ${viewport.key}:\n${overflow.join('\n')}',
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
