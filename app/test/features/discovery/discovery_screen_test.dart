import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/profile.dart';
import 'package:dreem_world/data/providers/app_providers.dart';
import 'package:dreem_world/data/repositories/mock_profile_repository.dart';
import 'package:dreem_world/data/services/scoring_service.dart';
import 'package:dreem_world/features/discovery/discovery_screen.dart';

void main() {
  late Profile me;
  late List<Profile> candidates;

  setUp(() {
    me = MockProfileRepository.seedProfiles.first;
    candidates = MockProfileRepository.seedProfiles.skip(1).toList();
  });

  Stream<T> immediate<T>(T value) {
    final StreamController<T> controller = StreamController<T>();
    controller.add(value);
    controller.close();
    return controller.stream;
  }

  List<Override> overrides() => <Override>[
    currentProfileProvider.overrideWith((Ref ref) => immediate<Profile?>(me)),
    discoveryProfilesProvider.overrideWith(
      (Ref ref) => immediate<List<Profile>>(candidates),
    ),
  ];

  test('ранжированный подбор отдаёт данные при первом чтении', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: overrides(),
    );
    addTearDown(container.dispose);

    await container.read(currentProfileProvider.future);
    await container.read(discoveryProfilesProvider.future);

    final AsyncValue<List<ScoredProfile>> value = container.read(
      rankedDiscoveryProfilesProvider,
    );

    expect(
      value.hasValue,
      isTrue,
      reason: 'Подбор не должен оставаться в loading',
    );
    expect(value.asData!.value.first.profile.id, candidates.first.id);
  });

  testWidgets('экран подбора показывает карточку без вечного индикатора', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const DiscoveryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(candidates.first.name), findsWidgets);
    expect(find.text('Нравится'), findsOneWidget);
  });
}
