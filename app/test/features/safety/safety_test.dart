import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/index.dart';
import 'package:dreem_world/data/services/moderation_service.dart';
import 'package:dreem_world/features/safety/age_safety.dart';
import 'package:dreem_world/features/safety/safety_center_screen.dart';
import 'package:dreem_world/features/safety/safety_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ИИ-модерация (заглушка)', () {
    const ModerationService moderation = MockModerationService();

    test('пропускает безопасный текст', () {
      final ModerationVerdict verdict =
          moderation.checkText('Привет! Как дела? Люблю музыку и кино.');
      expect(verdict.flagged, isFalse);
    });

    test('ловит мошенничество и запрещённый контент', () {
      expect(
        moderation.checkText('Переведи на карту 5000 рублей').flagged,
        isTrue,
      );
      expect(moderation.checkText('есть интим услуги').flagged, isTrue);
      expect(moderation.checkText('заходи на https://spam.example').flagged, isTrue);
    });

    test('ловит оскорбления', () {
      final ModerationVerdict verdict =
          moderation.checkText('ты дебил, заткнись');
      expect(verdict.flagged, isTrue);
      expect(verdict.reasons, contains(ReportReason.harassment));
    });
  });

  group('Возрастная безопасность', () {
    test('запрещает личный чат ребёнок-взрослый', () {
      expect(
        AgeSafety.canChatPrivately(myAge: 15, otherAge: 30),
        isFalse,
      );
      expect(
        AgeSafety.restrictionReason(myAge: 15, otherAge: 30),
        isNotNull,
      );
    });

    test('разрешает чат между сверстниками и взрослыми', () {
      expect(AgeSafety.canChatPrivately(myAge: 16, otherAge: 17), isTrue);
      expect(AgeSafety.canChatPrivately(myAge: 22, otherAge: 35), isTrue);
    });
  });

  group('Контроллер безопасности', () {
    test('серьёзная жалоба принимается автоматически и скрывается', () {
      final SafetyController controller = SafetyController();
      final Report report = controller.submitReport(
        targetId: 'p_bad',
        targetName: 'Злоумышленник',
        target: ReportTarget.user,
        reason: ReportReason.scam,
      );
      expect(report.status, ReportStatus.actionTaken);
      expect(report.autoHidden, isTrue);
      expect(controller.state.reports, hasLength(1));
    });

    test('лёгкая жалоба уходит на проверку', () {
      final SafetyController controller = SafetyController();
      final Report report = controller.submitReport(
        targetId: 'p_x',
        targetName: 'Спамер',
        target: ReportTarget.user,
        reason: ReportReason.spam,
      );
      expect(report.status, ReportStatus.underReview);
      expect(report.autoHidden, isFalse);
    });

    test('блокировка и разблокировка работают', () {
      final SafetyController controller = SafetyController();
      controller.block(userId: 'p_bad', name: 'Плохой');
      expect(controller.state.isBlocked('p_bad'), isTrue);
      expect(controller.state.blocked, hasLength(1));

      controller.block(userId: 'p_bad', name: 'Плохой');
      expect(controller.state.blocked, hasLength(1));

      controller.unblock('p_bad');
      expect(controller.state.isBlocked('p_bad'), isFalse);
    });

    test('блокировки сохраняются и восстанавливаются', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SafetyController first = SafetyController(storageKey: 'blocked_t');
      first.block(userId: 'u_bad', name: 'Плохой', reason: 'Спам');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('blocked_t'), isNotNull);

      final SafetyController second = SafetyController(storageKey: 'blocked_t');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(second.state.isBlocked('u_bad'), isTrue);
      expect(second.state.blocked.single.name, 'Плохой');
    });
  });

  testWidgets('Центр безопасности показывает правила', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.of(AppThemeName.neonViolet),
          home: const SafetyCenterScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Центр безопасности'), findsOneWidget);
    expect(find.text('Основные правила'), findsOneWidget);
    expect(find.text('Мои жалобы'), findsOneWidget);
    expect(find.text('Заблокированные'), findsOneWidget);
  });
}
