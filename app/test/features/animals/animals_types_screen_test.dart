import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/animals/presentation/screens/animals_types_screen.dart';
import 'package:dreem_world/features/animals/presentation/widgets/animals_navigation_rail.dart';
import 'package:dreem_world/features/animals/presentation/widgets/animals_types_data.dart';
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
  initialLocation: '/main/planet/p_animals/types',
  routes: <RouteBase>[
    GoRoute(
      path: '/main/planet/p_animals/types',
      builder: (BuildContext context, GoRouterState state) =>
          const AnimalsTypesScreen(),
    ),
    GoRoute(
      path: '/main/planet/p_animals',
      builder: (BuildContext context, GoRouterState state) =>
          const _Stub('animals'),
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

    final AnimalsNavigationRail rail = tester.widget<AnimalsNavigationRail>(
      find.byType(AnimalsNavigationRail),
    );
    expect(rail.activeLabel, 'Виды животных');
    expect(rail.compact, isFalse);
    expect(
      find.byKey(const ValueKey<String>('animals-nav-Карта')),
      findsOneWidget,
    );

    expect(find.text('Виды животных'), findsWidgets);
    expect(find.text('Все виды животных'), findsOneWidget);
    expect(find.text('Советы новичкам'), findsOneWidget);
    expect(find.text('Главные ошибки хозяина'), findsOneWidget);
    expect(find.text('Безопасность и правила'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('animals-types-sources')),
      findsOneWidget,
    );

    for (final AnimalsTypeInfo type in AnimalsTypesData.types) {
      expect(
        find.byKey(ValueKey<String>('animals-type-card-${type.title}')),
        findsOneWidget,
        reason: 'не найдена карточка ${type.title}',
      );
    }
    for (final AnimalsTip tip in AnimalsTypesData.beginnerTips) {
      expect(
        find.byKey(ValueKey<String>('animals-beginner-tip-${tip.title}')),
        findsOneWidget,
      );
    }
    for (final AnimalsMistake mistake in AnimalsTypesData.commonMistakes) {
      expect(
        find.byKey(ValueKey<String>('animals-mistake-${mistake.title}')),
        findsOneWidget,
      );
    }
    for (final AnimalsSafetyRule rule in AnimalsTypesData.safetyRules) {
      expect(
        find.byKey(ValueKey<String>('animals-safety-${rule.title}')),
        findsOneWidget,
      );
    }
  });

  testWidgets('карточка раскрывает детали, фильтр переключает список', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const Size(1440, 1000));

    final Finder card = find.byKey(
      const ValueKey<String>('animals-type-card-Собаки'),
    );
    await tester.ensureVisible(card);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(card);
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey<String>('animals-type-details-Собаки')),
      findsOneWidget,
    );
    expect(
      find.textContaining('Собаки — первые прирученные'),
      findsOneWidget,
    );

    final Finder birdFilter = find.byKey(
      const ValueKey<String>('animals-type-filter-Птицы'),
    );
    await tester.ensureVisible(birdFilter);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(birdFilter);
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey<String>('animals-type-card-Попугаи')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animals-type-card-Собаки')),
      findsNothing,
    );

    final Finder allFilter = find.byKey(
      const ValueKey<String>('animals-type-filter-Все'),
    );
    await tester.ensureVisible(allFilter);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(allFilter);
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.byKey(const ValueKey<String>('animals-type-card-Собаки')),
      findsOneWidget,
    );
  });

  testWidgets('кнопка «Назад к животным» возвращает на портал', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const Size(1440, 1000));

    final Finder back = find.byKey(
      const ValueKey<String>('animals-types-back'),
    );
    await tester.ensureVisible(back);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(back);
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('МАРКЕР:animals'), findsOneWidget);
  });

  for (final MapEntry<String, Size> viewport in const <String, Size>{
    'SE1': Size(320, 568),
    'android': Size(360, 640),
    'iphone14': Size(390, 844),
    'iphone14 landscape': Size(844, 390),
    'desktop': Size(1440, 900),
  }.entries) {
    testWidgets('виды животных без переполнений: ${viewport.key}', (
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

    final AnimalsNavigationRail rail = tester.widget<AnimalsNavigationRail>(
      find.byType(AnimalsNavigationRail),
    );
    expect(rail.compact, isTrue);
    expect(
      find.byKey(const ValueKey<String>('animals-nav-Виды животных')),
      findsOneWidget,
    );
  });
}
