import 'package:dreem_world/features/auth/forgot_password_screen.dart';
import 'package:dreem_world/features/auth/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('восстановление пароля проверяет email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
    );

    await tester.tap(find.text('Отправить ссылку'));
    await tester.pump();

    expect(find.text('Введите email'), findsOneWidget);
  });

  testWidgets('новый пароль требует совпадающее подтверждение', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ResetPasswordScreen())),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'secret1');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret2');
    await tester.tap(find.text('Сохранить пароль'));
    await tester.pump();

    expect(find.text('Пароли не совпадают'), findsOneWidget);
  });
}
