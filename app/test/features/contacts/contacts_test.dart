import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/data/models/index.dart';
import 'package:dreem_world/data/providers/app_providers.dart';
import 'package:dreem_world/data/services/user_code.dart';
import 'package:dreem_world/features/contacts/contacts_controller.dart';
import 'package:dreem_world/features/contacts/contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Контакты', () {
    test('контроллер добавляет и удаляет контакты без дублей', () {
      final ContactsController controller = ContactsController();

      expect(controller.state, isEmpty);
      controller.add('p_anna');
      controller.add('p_leo');
      controller.add('p_anna'); // дубль игнорируется
      expect(controller.state, <String>['p_anna', 'p_leo']);
      expect(controller.contains('p_leo'), isTrue);

      controller.remove('p_anna');
      expect(controller.state, <String>['p_leo']);
    });

    testWidgets('экран контактов показывает свой ID и кнопку поиска', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.of(AppThemeName.neonViolet),
            home: const ContactsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Ваш ID'), findsOneWidget);
      expect(find.text(UserCode.fromUserId('me')), findsOneWidget);
      expect(find.text('Найти по ID'), findsOneWidget);
      expect(find.text('Пока нет контактов'), findsOneWidget);
      expect(find.text('Мой QR'), findsNothing);
    });

    test('поиск по ID находит демо-анкету', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final String code = UserCode.fromUserId('p_anna');
      final List<Profile> found = await container.read(
        profileSearchProvider(code).future,
      );

      expect(found.map((Profile profile) => profile.id), contains('p_anna'));
    });

    test('неполный и неизвестный ID ничего не находит', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        await container.read(profileSearchProvider('DW-7K4').future),
        isEmpty,
      );
      expect(
        await container.read(
          profileSearchProvider(UserCode.fromUserId('нет-такого')).future,
        ),
        isEmpty,
      );
    });
  });
}
