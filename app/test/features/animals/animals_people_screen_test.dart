import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/animals/presentation/screens/animals_people_screen.dart';
import 'package:dreem_world/features/animals/presentation/widgets/animals_navigation_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _Stub extends StatelessWidget {
  const _Stub(this.marker);

  final String marker;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text('МАРКЕР:$marker'));
}

GoRouter _router() => GoRouter(
  initialLocation: '/main/planet/p_animals/people',
  routes: <RouteBase>[
    GoRoute(
      path: '/main/planet/p_animals/people',
      builder: (BuildContext context, GoRouterState state) =>
          const AnimalsPeopleScreen(),
    ),
    GoRoute(
      path: '/main/planet/p_animals',
      builder: (BuildContext context, GoRouterState state) =>
          const _Stub('animals'),
    ),
    GoRoute(
      path: '/user/:id',
      builder: (BuildContext context, GoRouterState state) =>
          _Stub('user:${state.pathParameters['id']}'),
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (BuildContext context, GoRouterState state) =>
          _Stub('chat:${state.pathParameters['id']}'),
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
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.of(AppThemeName.neonViolet),
          routerConfig: _router(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    while (tester.takeException() != null) {}
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('широкий экран показывает список участников', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const Size(1440, 1000));

    final AnimalsNavigationRail rail = tester.widget<AnimalsNavigationRail>(
      find.byType(AnimalsNavigationRail),
    );
    expect(rail.activeLabel, 'Люди');
    expect(rail.compact, isFalse);
    expect(
      find.byKey(const ValueKey<String>('animals-nav-Карта')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animals-people-back')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animals-people-search')),
      findsOneWidget,
    );
    expect(find.text('Люди сообщества'), findsOneWidget);
    expect(find.text('Участники планеты'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('animals-people-list')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animals-people-card-p_anna')),
      findsOneWidget,
    );
  });

  testWidgets('поиск фильтрует участников', (WidgetTester tester) async {
    await pumpScreen(tester, const Size(1440, 1000));

    expect(
      find.byKey(const ValueKey<String>('animals-people-card-p_anna')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('animals-people-search')),
      'Анна',
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey<String>('animals-people-card-p_anna')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('animals-people-card-p_leo')),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('animals-people-search')),
      'несуществующий город',
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.byKey(const ValueKey<String>('animals-people-empty')),
      findsOneWidget,
    );
  });

  testWidgets('кнопка «Назад к животным» возвращает на портал', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, const Size(1440, 1000));

    final Finder back = find.byKey(
      const ValueKey<String>('animals-people-back'),
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
    testWidgets('люди без переполнений: ${viewport.key}', (
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
      find.byKey(const ValueKey<String>('animals-nav-Люди')),
      findsOneWidget,
    );
  });
}
