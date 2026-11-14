import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/data/models/app_user.dart';
import 'package:dreem_world/data/services/auth_service.dart';
import 'package:dreem_world/data/services/mock_auth_service.dart';
import 'package:dreem_world/features/auth/register_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('MockAuthService', () {
    test('register создаёт пользователя и сессию', () async {
      final MockAuthService service = MockAuthService();

      final RegistrationResult result = await service.register(
        email: 'user@example.com',
        password: 'secret1',
        name: 'Иван',
      );
      final AppUser user = result.user;

      expect(result.emailConfirmationRequired, isFalse);
      expect(user.email, 'user@example.com');
      expect(user.name, 'Иван');
      expect(user.id, isNotEmpty);

      final AppUser? restored = await service.restoreSession();
      expect(restored, isNotNull);
      expect(restored, user);
    });

    test('повторный register с тем же email бросает AuthException', () async {
      final MockAuthService service = MockAuthService();

      await service.register(
        email: 'user@example.com',
        password: 'secret1',
        name: 'Иван',
      );

      await expectLater(
        service.register(
          email: 'USER@example.com',
          password: 'other1',
          name: 'Другой',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('login с неверным паролем бросает, с верным — входит', () async {
      final MockAuthService service = MockAuthService();
      await service.register(
        email: 'user@example.com',
        password: 'secret1',
        name: 'Иван',
      );
      await service.logout();
      expect(await service.restoreSession(), isNull);

      await expectLater(
        service.login(email: 'user@example.com', password: 'wrong'),
        throwsA(isA<AuthException>()),
      );

      final AppUser user = await service.login(
        email: 'user@example.com',
        password: 'secret1',
      );
      expect(user.email, 'user@example.com');
      expect(await service.restoreSession(), user);
    });

    test('logout очищает сессию', () async {
      final MockAuthService service = MockAuthService();
      await service.register(
        email: 'user@example.com',
        password: 'secret1',
        name: 'Иван',
      );
      expect(await service.restoreSession(), isNotNull);

      await service.logout();
      expect(await service.restoreSession(), isNull);
    });
  });

  group('RegisterScreen', () {
    testWidgets('рендерится и показывает ошибки валидации пустых полей', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: RegisterScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Создать аккаунт'), findsWidgets);
      expect(find.text('Имя'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Создать аккаунт'));
      await tester.pumpAndSettle();

      expect(find.text('Введите имя'), findsOneWidget);
      expect(find.text('Введите email'), findsOneWidget);
      expect(find.text('Введите пароль'), findsOneWidget);
      expect(find.text('Введите пароль ещё раз'), findsOneWidget);
    });

    testWidgets('показывает ошибку при некорректном email и коротком пароле', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: RegisterScreen())),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Иван');
      await tester.enterText(find.byType(TextFormField).at(1), 'not-an-email');
      await tester.enterText(find.byType(TextFormField).at(2), '123');
      await tester.enterText(find.byType(TextFormField).at(3), '456');

      await tester.tap(find.widgetWithText(FilledButton, 'Создать аккаунт'));
      await tester.pumpAndSettle();

      expect(find.text('Некорректный email'), findsOneWidget);
      expect(
        find.text('Пароль должен быть не короче 6 символов'),
        findsOneWidget,
      );
      expect(find.text('Пароли не совпадают'), findsOneWidget);
    });
  });
}
