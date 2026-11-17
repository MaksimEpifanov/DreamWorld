import 'dart:convert';

import 'package:dreem_world/data/models/app_user.dart';
import 'package:dreem_world/data/models/interest.dart';
import 'package:dreem_world/data/models/profile.dart';
import 'package:dreem_world/data/providers/app_providers.dart';
import 'package:dreem_world/data/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Profile.hasSetupContent', () {
    test('техническая заготовка считается незаполненной', () {
      const Profile stub = Profile(id: 'u1', name: 'Иван', age: 18);
      expect(stub.hasSetupContent, isFalse);
    });

    test('город, описание или интересы означают заполненную анкету', () {
      const Profile byCity = Profile(
        id: 'u1',
        name: 'Иван',
        age: 25,
        city: 'Москва',
      );
      expect(byCity.hasSetupContent, isTrue);

      const Profile byBio = Profile(
        id: 'u1',
        name: 'Иван',
        age: 25,
        bio: 'Люблю горы',
      );
      expect(byBio.hasSetupContent, isTrue);

      const Profile byInterests = Profile(
        id: 'u1',
        name: 'Иван',
        age: 25,
        interests: <Interest>[InterestCatalog.music],
      );
      expect(byInterests.hasSetupContent, isTrue);
    });
  });

  group('Profile: запросы в контакты', () {
    test('по умолчанию списки запросов пусты', () {
      const Profile stub = Profile(id: 'u1', name: 'Иван', age: 18);
      expect(stub.incomingContactRequestIds, isEmpty);
      expect(stub.outgoingContactRequestIds, isEmpty);
      expect(stub.hasIncomingContactRequest('u2'), isFalse);
      expect(stub.hasOutgoingContactRequest('u2'), isFalse);
    });

    test('JSON сохраняет и читает списки запросов', () {
      const Profile profile = Profile(
        id: 'u1',
        name: 'Иван',
        age: 20,
        incomingContactRequestIds: <String>['u2'],
        outgoingContactRequestIds: <String>['u3'],
      );
      final Profile restored = Profile.fromJson(
        jsonDecode(jsonEncode(profile.toJson())) as Map<String, dynamic>,
      );
      expect(restored.incomingContactRequestIds, <String>['u2']);
      expect(restored.outgoingContactRequestIds, <String>['u3']);
      expect(restored.hasIncomingContactRequest('u2'), isTrue);
      expect(restored.hasOutgoingContactRequest('u3'), isTrue);
    });
  });

  group('hasSavedProfileProvider', () {
    const AppUser user = AppUser(
      id: 'u1',
      email: 'u1@example.com',
      name: 'Иван',
    );

    ProviderContainer containerFor() {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          currentUserFromAuthProvider.overrideWithValue(user),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    void seedProfile(Profile profile) {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'saved_profile_${profile.id}': jsonEncode(profile.toJson()),
      });
    }

    test('без анкеты просит заполнить', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ProviderContainer container = containerFor();
      expect(await container.read(hasSavedProfileProvider.future), isFalse);
    });

    test('заготовка без данных просит заполнить', () async {
      seedProfile(const Profile(id: 'u1', name: 'Иван', age: 18));
      final ProviderContainer container = containerFor();
      expect(await container.read(hasSavedProfileProvider.future), isFalse);
    });

    test('заполненная анкета не просит заполнять повторно', () async {
      seedProfile(
        const Profile(id: 'u1', name: 'Иван', age: 25, city: 'Москва'),
      );
      final ProviderContainer container = containerFor();
      expect(await container.read(hasSavedProfileProvider.future), isTrue);
    });

    test('после «Пропустить» анкету не спрашивают снова', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        profileSetupDismissedKey('u1'): true,
      });
      final ProviderContainer container = containerFor();
      expect(await container.read(hasSavedProfileProvider.future), isTrue);
    });
  });
}
