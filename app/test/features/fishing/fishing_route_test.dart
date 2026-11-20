import 'dart:convert';

import 'package:dreem_world/app.dart';
import 'package:dreem_world/data/models/app_user.dart';
import 'package:dreem_world/data/models/profile.dart';
import 'package:dreem_world/data/repositories/mock_profile_repository.dart';
import 'package:dreem_world/data/services/mock_auth_service.dart';
import 'package:dreem_world/features/fishing/presentation/screens/fishing_screen.dart';
import 'package:dreem_world/features/fishing/presentation/screens/fishing_people_screen.dart';
import 'package:dreem_world/features/fishing/presentation/screens/fishing_types_screen.dart';
import 'package:dreem_world/features/planets/map/planet_map_screen.dart';
import 'package:dreem_world/features/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GoRouter> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  const AppUser user = AppUser(
    id: 'u1',
    email: 'user@example.com',
    name: 'Иван',
  );
  final Profile profile = Profile(
    id: 'u1',
    name: 'Иван',
    age: 25,
    city: 'Москва',
  );
  SharedPreferences.setMockInitialValues(<String, Object>{
    MockAuthService.currentSessionKey: jsonEncode(user.toJson()),
    MockProfileRepository.savedProfileKey: jsonEncode(profile.toJson()),
  });

  await tester.pumpWidget(const ProviderScope(child: DreemWorldApp()));
  await tester.pump(const Duration(milliseconds: 500));
  while (tester.takeException() != null) {}

  final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
  return app.routerConfig! as GoRouter;
}

Future<void> _go(WidgetTester tester, GoRouter router, String path) async {
  router.go(path);
  for (int i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    tester.takeException();
  }
}

void main() {
  testWidgets(
    'реальный роутер открывает FishingScreen по /main/planet/p_fishing',
    (WidgetTester tester) async {
      final GoRouter router = await _pumpApp(tester);
      await _go(tester, router, '/main/planet/p_fishing');

      expect(
        find.byType(FishingScreen),
        findsOneWidget,
        reason:
            'по /main/planet/p_fishing должен открываться портал рыбалки, '
            'а не старая планета. Текущий путь: ${router.state.uri}',
      );
      expect(
        find.byType(AppShell),
        findsNothing,
        reason: 'верхняя и нижняя панели должны быть убраны',
      );
    },
  );

  testWidgets('карта рыбалки остаётся доступной как полноэкранный маршрут', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpApp(tester);
    await _go(tester, router, '/main/planet/p_fishing/map');

    expect(
      find.byType(PlanetMapScreen),
      findsOneWidget,
      reason: 'Текущий путь: ${router.state.uri}',
    );
  });

  testWidgets('реальный роутер открывает экран «Виды ловли»', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpApp(tester);
    await _go(tester, router, '/main/planet/p_fishing/types');

    expect(
      find.byType(FishingTypesScreen),
      findsOneWidget,
      reason: 'Текущий путь: ${router.state.uri}',
    );
    expect(find.byType(AppShell), findsNothing);
    expect(find.text('Виды ловли'), findsWidgets);
    expect(find.text('Все виды ловли'), findsOneWidget);
    expect(find.text('Советы новичкам'), findsOneWidget);
    expect(find.text('Главные ошибки рыбака'), findsOneWidget);
    expect(find.text('Безопасность и правила'), findsOneWidget);
  });

  testWidgets('кнопка слева «Виды ловли» открывает новый экран', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpApp(tester);
    await _go(tester, router, '/main/planet/p_fishing');

    final Finder button = find.byKey(
      const ValueKey<String>('fishing-nav-Виды ловли'),
    );
    expect(button, findsOneWidget);
    await tester.ensureVisible(button);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(button);
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      tester.takeException();
    }

    expect(
      find.byType(FishingTypesScreen),
      findsOneWidget,
      reason: 'Текущий путь: ${router.state.uri}',
    );
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets('реальный роутер открывает экран «Люди»', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpApp(tester);
    await _go(tester, router, '/main/planet/p_fishing/people');

    expect(
      find.byType(FishingPeopleScreen),
      findsOneWidget,
      reason: 'Текущий путь: ${router.state.uri}',
    );
    expect(find.byType(AppShell), findsNothing);
    expect(find.text('Люди сообщества'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('fishing-people-search')), findsOneWidget);
  });

  testWidgets('кнопка слева «Люди» открывает список участников', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpApp(tester);
    await _go(tester, router, '/main/planet/p_fishing');

    final Finder button = find.byKey(
      const ValueKey<String>('fishing-nav-Люди'),
    );
    expect(button, findsOneWidget);
    await tester.ensureVisible(button);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(button);
    for (int i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      tester.takeException();
    }

    expect(
      find.byType(FishingPeopleScreen),
      findsOneWidget,
      reason: 'Текущий путь: ${router.state.uri}',
    );
    expect(find.byType(AppShell), findsNothing);
  });
}
