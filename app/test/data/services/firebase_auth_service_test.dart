import 'package:dreem_world/data/providers/auth_providers.dart';
import 'package:dreem_world/data/services/firebase_bootstrap.dart';
import 'package:dreem_world/data/services/mock_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authServiceProvider', () {
    test('без настроенного Firebase использует MockAuthService', () {
      expect(isFirebaseInitialized, isFalse);

      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(authServiceProvider), isA<MockAuthService>());
    });
  });
}
