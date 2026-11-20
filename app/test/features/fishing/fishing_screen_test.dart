import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/fishing/presentation/screens/fishing_screen.dart';
import 'package:dreem_world/features/fishing/presentation/widgets/fishing_navigation_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _Stub extends StatelessWidget {
  const _Stub(this.marker);

  final String marker;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text('МАРКЕР:$marker'));
}

GoRouter _router() => GoRouter(
  initialLocation: '/main/planet/p_fishing',
  routes: <RouteBase>[
    GoRoute(
      path: '/main/planet/p_fishing',
      builder: (BuildContext context, GoRouterState state) =>
          const FishingScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (BuildContext context, GoRouterState state) =>
          const _Stub('main'),
    ),
    GoRoute(
      path: '/main/planets',
      builder: (BuildContext context, GoRouterState state) =>
          const _Stub('planets'),
    ),
    GoRoute(
      path: '/search',
      builder: (BuildContext context, GoRouterState state) =>
          const _Stub('search'),
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) =>
          const _Stub('profile'),
    ),
    GoRoute(
      path: '/chats',
      builder: (BuildContext context, GoRouterState state) =>
          const _Stub('chats'),
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) =>
          const _Stub('settings'),
    ),
    for (final String suffix in <String>[
      'types',
      'people',
      'events',
      'chat',
      'map',
      'news',
    ])
      GoRoute(
        path: '/main/planet/p_fishing/$suffix',
        builder: (BuildContext context, GoRouterState state) => _Stub(suffix),
      ),
  ],
);

void main() {
  Future<void> pumpScreen(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.of(AppThemeName.neonViolet),
        routerConfig: _router(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    while (tester.takeException() != null) {}
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('широкий экран показывает три колонки и весь контент', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const Size(1440, 1000));

    expect(find.byType(FishingScreen), findsOneWidget);
    expect(find.byType(FishingNavigationRail), findsOneWidget);
    expect(find.text('FishWorld'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('fishing-nav-Рыбалка')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('fishing-nav-Карта')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('fishing-nav-Настройки')),
      findsOneWidget,
    );
    expect(find.text('Рыбалка'), findsWidgets);
    expect(find.text('Озера, реки и большой улов'), findsOneWidget);
    expect(find.text('2 987 участников'), findsOneWidget);
    expect(find.text('Сейчас онлайн: 143'), findsOneWidget);
    expect(find.text('Трофей дня'), findsOneWidget);
    expect(find.text('Щука на 12 кг: секреты спиннинга'), findsOneWidget);
    expect(find.text('Направления'), findsOneWidget);
    expect(find.text('Все виды'), findsOneWidget);
    expect(find.text('Популярные снасти'), findsOneWidget);
    expect(find.text('Ближайшие события'), findsOneWidget);
    expect(find.text('Рекомендуемые люди'), findsOneWidget);
    expect(find.text('Онлайн'), findsWidgets);
    expect(find.text('Оффлайн'), findsOneWidget);
    expect(find.text('Турнир по спиннингу'), findsOneWidget);
    expect(find.text('Выезд на карпа'), findsOneWidget);
    expect(find.text('Мастер-класс по нахлысту'), findsOneWidget);
    expect(find.text('Рыбак_Иван'), findsWidgets);
    expect(find.text('Щукарь_99'), findsWidgets);
    expect(find.text('Делитесь уловами с сообществом'), findsOneWidget);

    for (final String title in <String>[
      'Спиннинг',
      'Фидер',
      'Поплавок',
      'Зимняя рыбалка',
      'Нахлыст',
      'Морская рыбалка',
    ]) {
      expect(
        find.byKey(ValueKey<String>('fishing-direction-$title')),
        findsOneWidget,
        reason: 'не найдена карточка направления $title',
      );
    }

    final GridView grid = tester.widget<GridView>(
      find.byKey(const ValueKey<String>('fishing-directions-grid')),
    );
    final SliverGridDelegateWithFixedCrossAxisCount delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(
      delegate.crossAxisCount,
      3,
      reason: 'сетка направлений должна быть 3×2',
    );

    for (final String label in <String>[
      'Главная',
      'Виды ловли',
      'Новости',
      'Люди',
      'События',
      'Карта',
      'Чат',
    ]) {
      expect(
        find.byKey(ValueKey<String>('fishing-tab-$label')),
        findsOneWidget,
        reason: 'не найден таб $label',
      );
    }
  });

  testWidgets('табы и подписка работают', (WidgetTester tester) async {
    await pumpScreen(tester, const Size(1440, 1000));

    await tester.tap(
      find.byKey(const ValueKey<String>('fishing-tab-Главная')),
    );
    await tester.pump(const Duration(milliseconds: 400));

    final Finder follow = find.byKey(
      const ValueKey<String>('fishing-follow-Рыбак_Иван'),
    );
    await tester.ensureVisible(follow);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(follow);
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('табы в центральной колонке ведут на нужные экраны', (
    WidgetTester tester,
  ) async {
    for (final MapEntry<String, String> target in const <String, String>{
      'Виды ловли': 'types',
      'Новости': 'news',
      'Люди': 'people',
      'События': 'events',
    }.entries) {
      await pumpScreen(tester, const Size(1440, 1000));

      final Finder tab = find.byKey(
        ValueKey<String>('fishing-tab-${target.key}'),
      );
      expect(tab, findsOneWidget);
      await tester.tap(tab);
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        tester.takeException();
      }

      expect(
        find.text('МАРКЕР:${target.value}'),
        findsOneWidget,
        reason: 'таб «${target.key}» должен открыть /main/planet/p_fishing/${target.value}',
      );
    }
  });

  testWidgets('кнопка «Все виды» открывает все виды ловли', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const Size(1440, 1000));

    await tester.tap(find.byKey(const ValueKey<String>('fishing-show-all')));
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      tester.takeException();
    }

    expect(find.text('МАРКЕР:types'), findsOneWidget);
  });

  for (final MapEntry<String, Size> viewport in const <String, Size>{
    'SE1': Size(320, 568),
    'android': Size(360, 640),
    'iphone14': Size(390, 844),
    'iphone14 landscape': Size(844, 390),
    'desktop': Size(1440, 900),
  }.entries) {
    testWidgets('рыбалка без переполнений: ${viewport.key}', (
      WidgetTester tester,
    ) async {
      final List<String> problems = <String>[];
      final void Function(FlutterErrorDetails)? previous = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        problems.add(details.toString());
      };
      try {
        await pumpScreen(tester, viewport.value);
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

  testWidgets('на узком экране рельс иконок остаётся, правый уходит вниз', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const Size(390, 844));

    final FishingNavigationRail rail = tester.widget<FishingNavigationRail>(
      find.byType(FishingNavigationRail),
    );
    expect(rail.compact, isTrue);
    expect(
      find.byKey(const ValueKey<String>('fishing-nav-Карта')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('fishing-popular-panel')),
      findsOneWidget,
    );
    expect(find.text('Популярные снасти'), findsOneWidget);
    expect(find.text('Ближайшие события'), findsOneWidget);
    expect(find.text('Рекомендуемые люди'), findsOneWidget);
  });
}
