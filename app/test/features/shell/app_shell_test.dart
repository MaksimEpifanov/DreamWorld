import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/features/shell/app_shell.dart';

void main() {
  group('AppNavigationBar', () {
    testWidgets('показывает пять разделов и передаёт выбор вкладки', (
      WidgetTester tester,
    ) async {
      final List<int> selected = <int>[];
      final GoRouter router = GoRouter(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return Scaffold(
                body: const SizedBox.expand(),
                bottomNavigationBar: AppNavigationBar(
                  currentIndex: 0,
                  onDestinationSelected: selected.add,
                ),
              );
            },
          ),
          GoRoute(
            path: '/main/planet/p_travel/news',
            builder: (BuildContext context, GoRouterState state) =>
                const Scaffold(body: Text('События')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.of(AppThemeName.neonViolet),
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Планеты'), findsOneWidget);
      expect(find.text('Поиск'), findsOneWidget);
      expect(find.text('События'), findsOneWidget);
      expect(find.text('Чаты'), findsOneWidget);
      expect(find.text('Контакты'), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));

      await tester.tap(find.text('Чаты'));
      await tester.pumpAndSettle();
      expect(selected, <int>[2]);

      await tester.tap(find.text('Контакты'));
      await tester.pumpAndSettle();
      expect(selected, <int>[2, 3]);

      await tester.tap(find.text('События'));
      await tester.pumpAndSettle();
      expect(find.text('События'), findsOneWidget);
    });
  });
}
