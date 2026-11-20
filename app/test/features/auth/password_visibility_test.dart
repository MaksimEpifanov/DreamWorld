import 'package:dreem_world/features/auth/login_screen.dart';
import 'package:dreem_world/features/auth/register_screen.dart';
import 'package:dreem_world/features/auth/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int obscuredFields(WidgetTester tester) => tester
      .widgetList<TextField>(
        find.byWidgetPredicate(
          (Widget widget) => widget is TextField && widget.obscureText,
        ),
      )
      .length;

  testWidgets('вход: глазик показывает и скрывает пароль', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    await tester.pumpAndSettle();

    expect(obscuredFields(tester), 1);
    expect(find.byTooltip('Показать пароль'), findsOneWidget);

    await tester.tap(find.byTooltip('Показать пароль'));
    await tester.pumpAndSettle();

    expect(obscuredFields(tester), 0);
    expect(find.byTooltip('Скрыть пароль'), findsOneWidget);

    await tester.tap(find.byTooltip('Скрыть пароль'));
    await tester.pumpAndSettle();

    expect(obscuredFields(tester), 1);
  });

  testWidgets('регистрация: у каждого пароля свой глазик', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RegisterScreen())),
    );
    await tester.pumpAndSettle();

    expect(obscuredFields(tester), 2);
    expect(find.byTooltip('Показать пароль'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Показать пароль').first);
    await tester.pumpAndSettle();

    expect(obscuredFields(tester), 1);
    expect(find.byTooltip('Показать пароль'), findsOneWidget);
    expect(find.byTooltip('Скрыть пароль'), findsOneWidget);
  });

  testWidgets('новый пароль: глазик переключает оба поля', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ResetPasswordScreen())),
    );
    await tester.pumpAndSettle();

    expect(obscuredFields(tester), 2);

    await tester.tap(find.byTooltip('Показать пароль').last);
    await tester.pumpAndSettle();

    expect(obscuredFields(tester), 1);
    expect(find.byTooltip('Скрыть пароль'), findsOneWidget);
  });
}
