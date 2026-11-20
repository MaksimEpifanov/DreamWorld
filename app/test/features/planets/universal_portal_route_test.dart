import 'dart:convert';

import 'package:dreem_world/app.dart';
import 'package:dreem_world/data/models/app_user.dart';
import 'package:dreem_world/data/models/profile.dart';
import 'package:dreem_world/data/repositories/mock_profile_repository.dart';
import 'package:dreem_world/data/services/mock_auth_service.dart';
import 'package:dreem_world/features/planets/map/planet_map_screen.dart';
import 'package:dreem_world/features/planets/portal/data/portal_catalog.dart';
import 'package:dreem_world/features/planets/portal/data/universal_portal_dataset.dart';
import 'package:dreem_world/features/planets/portal/presentation/screens/universal_planet_people_screen.dart';
import 'package:dreem_world/features/planets/portal/presentation/screens/universal_planet_portal_screen.dart';
import 'package:dreem_world/features/planets/portal/presentation/screens/universal_planet_types_screen.dart';
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

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(finder);
  for (int i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    tester.takeException();
  }
}

void main() {
  test('все универсальные планеты имеют зарегистрированный датасет', () {
    expect(PortalCatalog.universalPlanetIds, hasLength(19));

    for (final String id in PortalCatalog.universalPlanetIds) {
      final PortalDataset? data = PortalCatalog.dataset(id);
      expect(data, isNotNull, reason: 'нет датасета для $id');
      expect(data!.planetId, id);
      expect(data.types, hasLength(21), reason: '$id: типы');
      expect(data.tips, hasLength(10), reason: '$id: советы');
      expect(data.mistakes, hasLength(10), reason: '$id: ошибки');
      expect(data.safety, hasLength(5), reason: '$id: безопасность');
      expect(data.sources, hasLength(3), reason: '$id: источники');
      expect(PortalCatalog.isUniversal(id), isTrue, reason: '$id не универсальный');
    }

    expect(PortalCatalog.isUniversal('p_fishing'), isFalse);
    expect(PortalCatalog.isUniversal('p_animals'), isFalse);
  });

  testWidgets('универсальный портал открывается по /main/planet/p_travel', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpApp(tester);
    await _go(tester, router, '/main/planet/p_travel');

    expect(
      find.byType(UniversalPlanetPortalScreen),
      findsOneWidget,
      reason: 'Текущий путь: ${router.state.uri}',
    );
    expect(find.byType(AppShell), findsNothing);
    expect(find.text('Путешествий'), findsWidgets);
  });

  testWidgets('универсальный портал открывает экран «Виды»', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpApp(tester);
    await _go(tester, router, '/main/planet/p_travel/types');

    expect(
      find.byType(UniversalPlanetTypesScreen),
      findsOneWidget,
      reason: 'Текущий путь: ${router.state.uri}',
    );
    expect(find.byType(AppShell), findsNothing);
    expect(find.text('Виды путешествий'), findsWidgets);
    expect(find.text('Советы новичкам'), findsOneWidget);
    expect(find.text('Главные ошибки'), findsOneWidget);
    expect(find.text('Безопасность и правила'), findsOneWidget);
    expect(find.text('Источники информации'), findsOneWidget);
  });

  testWidgets('универсальный портал открывает экран «Люди»', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpApp(tester);
    await _go(tester, router, '/main/planet/p_travel/people');

    expect(
      find.byType(UniversalPlanetPeopleScreen),
      findsOneWidget,
      reason: 'Текущий путь: ${router.state.uri}',
    );
    expect(find.byType(AppShell), findsNothing);
    expect(find.text('Люди сообщества'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('portal-people-search-p_travel')),
      findsOneWidget,
    );
  });

  testWidgets('карта универсального портала остаётся полноэкранной', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpApp(tester);
    await _go(tester, router, '/main/planet/p_travel/map');

    expect(
      find.byType(PlanetMapScreen),
      findsOneWidget,
      reason: 'Текущий путь: ${router.state.uri}',
    );
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets('кнопка слева «Виды путешествий» открывает новый экран', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpApp(tester);
    await _go(tester, router, '/main/planet/p_travel');

    final Finder button = find.byKey(
      const ValueKey<String>('portal-nav-Виды путешествий'),
    );
    expect(button, findsOneWidget);
    await _tap(tester, button);

    expect(
      find.byType(UniversalPlanetTypesScreen),
      findsOneWidget,
      reason: 'Текущий путь: ${router.state.uri}',
    );
  });

  testWidgets('кнопка слева «Люди» открывает список участников', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpApp(tester);
    await _go(tester, router, '/main/planet/p_travel');

    final Finder button = find.byKey(
      const ValueKey<String>('portal-nav-Люди'),
    );
    expect(button, findsOneWidget);
    await _tap(tester, button);

    expect(
      find.byType(UniversalPlanetPeopleScreen),
      findsOneWidget,
      reason: 'Текущий путь: ${router.state.uri}',
    );
  });
}
