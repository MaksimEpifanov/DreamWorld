import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/fishing/presentation/screens/fishing_types_screen.dart';
import 'package:dreem_world/features/fishing/presentation/widgets/fishing_navigation_rail.dart';
import 'package:dreem_world/features/fishing/presentation/widgets/fishing_types_data.dart';
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
  initialLocation: '/main/planet/p_fishing/types',
  routes: <RouteBase>[
    GoRoute(
      path: '/main/planet/p_fishing/types',
      builder: (BuildContext context, GoRouterState state) =>
          const FishingTypesScreen(),
    ),
    GoRoute(
      path: '/main/planet/p_fishing',
      builder: (BuildContext context, GoRouterState state) =>
          const _Stub('fishing'),
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

  testWidgets('широкий экран показывает все разделы', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const Size(1440, 1000));

    final FishingNavigationRail rail = tester.widget<FishingNavigationRail>(
      find.byType(FishingNavigationRail),
    );
    expect(rail.activeLabel, 'Виды ловли');
    expect(rail.compact, isFalse);
    expect(find.byKey(const ValueKey<String>('fishing-nav-Карта')), findsOneWidget);

    expect(find.text('Виды ловли'), findsWidgets);
    expect(find.text('Все виды ловли'), findsOneWidget);
    expect(find.text('Советы новичкам'), findsOneWidget);
    expect(find.text('Главные ошибки рыбака'), findsOneWidget);
    expect(find.text('Безопасность и правила'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('fishing-types-sources')), findsOneWidget);

    for (final FishingTypeInfo type in FishingTypesData.types) {
      expect(
        find.byKey(ValueKey<String>('fishing-type-card-${type.title}')),
        findsOneWidget,
        reason: 'не найдена карточка ${type.title}',
      );
    }
    for (final FishingTip tip in FishingTypesData.beginnerTips) {
      expect(
        find.byKey(ValueKey<String>('fishing-beginner-tip-${tip.title}')),
        findsOneWidget,
      );
    }
    for (final FishingMistake mistake in FishingTypesData.commonMistakes) {
      expect(
        find.byKey(ValueKey<String>('fishing-mistake-${mistake.title}')),
        findsOneWidget,
      );
    }
    for (final FishingSafetyRule rule in FishingTypesData.safetyRules) {
      expect(
        find.byKey(ValueKey<String>('fishing-safety-${rule.title}')),
        findsOneWidget,
      );
    }
  });

  testWidgets('карточка раскрывает детали, фильтр переключает список', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const Size(1440, 1000));

    final Finder card = find.byKey(
      const ValueKey<String>('fishing-type-card-Спиннинг'),
    );
    await tester.ensureVisible(card);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(card);
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey<String>('fishing-type-details-Спиннинг')),
      findsOneWidget,
    );
    expect(find.textContaining('Тест удилища'), findsOneWidget);

    final Finder flyFilter = find.byKey(
      const ValueKey<String>('fishing-type-filter-Нахлыст'),
    );
    await tester.ensureVisible(flyFilter);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(flyFilter);
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey<String>('fishing-type-card-Нахлыст')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('fishing-type-card-Спиннинг')),
      findsNothing,
    );

    final Finder allFilter = find.byKey(
      const ValueKey<String>('fishing-type-filter-Все'),
    );
    await tester.ensureVisible(allFilter);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(allFilter);
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.byKey(const ValueKey<String>('fishing-type-card-Спиннинг')),
      findsOneWidget,
    );
  });

  testWidgets('кнопка «Назад к рыбалке» возвращает на портал', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const Size(1440, 1000));

    final Finder back = find.byKey(
      const ValueKey<String>('fishing-types-back'),
    );
    await tester.ensureVisible(back);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(back);
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('МАРКЕР:fishing'), findsOneWidget);
  });

  for (final MapEntry<String, Size> viewport in const <String, Size>{
    'SE1': Size(320, 568),
    'android': Size(360, 640),
    'iphone14': Size(390, 844),
    'iphone14 landscape': Size(844, 390),
    'desktop': Size(1440, 900),
  }.entries) {
    testWidgets('виды ловли без переполнений: ${viewport.key}', (
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

  testWidgets('на узком экране рельс иконок остаётся компактным', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const Size(390, 844));

    final FishingNavigationRail rail = tester.widget<FishingNavigationRail>(
      find.byType(FishingNavigationRail),
    );
    expect(rail.compact, isTrue);
    expect(
      find.byKey(const ValueKey<String>('fishing-nav-Виды ловли')),
      findsOneWidget,
    );
  });
}
