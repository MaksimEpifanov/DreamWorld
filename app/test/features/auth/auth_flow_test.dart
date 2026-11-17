import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/data/models/app_user.dart';
import 'package:dreem_world/data/providers/auth_providers.dart';
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

    test('в мок-режиме подтверждение почты не требуется', () async {
      final MockAuthService service = MockAuthService();

      final RegistrationResult result = await service.register(
        email: 'user@example.com',
        password: 'secret1',
        name: 'Иван',
      );

      expect(await service.pendingVerificationEmail(), isNull);
      expect(await service.reloadVerifiedUser(), result.user);
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

  group('AuthController: подтверждение почты', () {
    test('после «Продолжить без подтверждения» перезапуск не возвращает '
        'на экран подтверждения', () async {
      final _FakeAuthService service = _FakeAuthService(email: 'u@example.com');
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[authServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).restore();
      expect(
        container.read(authControllerProvider).status,
        AuthStatus.awaitingEmailVerification,
      );

      await container
          .read(authControllerProvider.notifier)
          .continueWithoutVerification();
      expect(container.read(authControllerProvider).isAuthenticated, isTrue);
      expect(
        container.read(authControllerProvider).pendingEmailVerification,
        isTrue,
      );

      final ProviderContainer restarted = ProviderContainer(
        overrides: <Override>[authServiceProvider.overrideWithValue(service)],
      );
      addTearDown(restarted.dispose);
      await restarted.read(authControllerProvider.notifier).restore();

      final AuthState restored = restarted.read(authControllerProvider);
      expect(restored.isAuthenticated, isTrue);
      expect(restored.pendingEmailVerification, isTrue);
    });

    test('без «Продолжить без подтверждения» перезапуск возвращает '
        'на экран подтверждения', () async {
      final _FakeAuthService service = _FakeAuthService(email: 'u@example.com');
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[authServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).restore();
      expect(
        container.read(authControllerProvider).status,
        AuthStatus.awaitingEmailVerification,
      );
    });

    test(
      'выход из аккаунта сбрасывает сохранённый пропуск подтверждения',
      () async {
        final _FakeAuthService service = _FakeAuthService(
          email: 'u@example.com',
        );
        final ProviderContainer container = ProviderContainer(
          overrides: <Override>[authServiceProvider.overrideWithValue(service)],
        );
        addTearDown(container.dispose);

        await container.read(authControllerProvider.notifier).restore();
        await container
            .read(authControllerProvider.notifier)
            .continueWithoutVerification();
        await container.read(authControllerProvider.notifier).logout();

        await container.read(authControllerProvider.notifier).restore();
        expect(
          container.read(authControllerProvider).status,
          AuthStatus.awaitingEmailVerification,
        );
      },
    );
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

class _FakeAuthService implements AuthService {
  _FakeAuthService({required this.email});

  final String email;

  AppUser get _user => AppUser(id: 'uid-1', email: email, name: 'Тест');

  @override
  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return RegistrationResult(user: _user, emailConfirmationRequired: true);
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    throw EmailNotVerifiedException(this.email);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AppUser?> restoreSession() async => null;

  @override
  AppUser? currentAccount() => _user;

  @override
  Future<String?> pendingVerificationEmail() async => email;

  @override
  Future<void> resendVerificationEmail() async {}

  @override
  Future<AppUser?> reloadVerifiedUser() async => null;

  @override
  Future<void> sendPasswordReset({required String email}) async {}

  @override
  Future<void> updatePassword({required String password}) async {}
}
