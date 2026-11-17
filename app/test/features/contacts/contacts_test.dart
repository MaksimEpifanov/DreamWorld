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
    test('контроллер добавляет и удаляет контакты в анкете', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(contactsProvider), isEmpty);

      await container.read(contactsControllerProvider).add('p_anna');
      await container.read(contactsControllerProvider).add('p_leo');
      await container.read(contactsControllerProvider).add('p_anna'); // дубль

      Profile? me = await container
          .read(profileRepositoryProvider)
          .getCurrentProfile();
      expect(me?.contactIds, <String>['p_anna', 'p_leo']);

      await container.read(contactsControllerProvider).remove('p_anna');
      me = await container
          .read(profileRepositoryProvider)
          .getCurrentProfile();
      expect(me?.contactIds, <String>['p_leo']);
    });

    test('контакт становится взаимным у обоих пользователей', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(contactsControllerProvider).add('p_anna');

      final Profile? other = await container
          .read(profileRepositoryProvider)
          .getProfileById('p_anna');
      expect(other?.contactIds, contains('me'));

      await container.read(contactsControllerProvider).remove('p_anna');

      final Profile? afterRemove = await container
          .read(profileRepositoryProvider)
          .getProfileById('p_anna');
      expect(afterRemove?.contactIds, isNot(contains('me')));
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

    test('провайдер профиля отдаёт анкету по ID и null для неизвестного', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final Profile? found = await container.read(
        userProfileProvider('p_anna').future,
      );
      expect(found?.id, 'p_anna');
      expect(found?.name, isNotEmpty);

      final Profile? missing = await container.read(
        userProfileProvider('нет-такого').future,
      );
      expect(missing, isNull);
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
