import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/index.dart';
import 'package:dreem_world/data/providers/app_providers.dart';
import 'package:dreem_world/features/profile/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Экран профиля другого пользователя', () {
    testWidgets('показывает описание, интересы, цели, ценности и языки', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const UserProfileScreen(userId: 'p_anna'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Анна'), findsWidgets);
      expect(find.text('О себе'), findsOneWidget);
      expect(
        find.text('Фотограф, люблю горы и долгие разговоры.'),
        findsOneWidget,
      );
      expect(find.text('Интересы'), findsOneWidget);
      expect(find.text('Цели знакомства'), findsOneWidget);
      expect(find.text('Ценности'), findsOneWidget);
      expect(find.text('Языки'), findsOneWidget);
    });

    test('профиль обновляется, когда собеседник заполняет анкету', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final Profile? before = await container.read(
        userProfileProvider('p_anna').future,
      );
      expect(before, isNotNull);

      await container
          .read(profileRepositoryProvider)
          .saveProfile(
            before!.copyWith(
              bio: 'Новое описание',
              interests: const <Interest>[],
            ),
          );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final Profile? after = await container.read(
        userProfileProvider('p_anna').future,
      );
      expect(after?.bio, 'Новое описание');
      expect(after?.interests, isEmpty);
    });
  });
}
