import 'package:dreem_world/data/providers/auth_providers.dart';
import 'package:dreem_world/data/services/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authServiceProvider', () {
    test('использует Supabase Auth', () {
      final SupabaseClient client = SupabaseClient(
        'https://example.supabase.co',
        'test-publishable-key',
      );
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[supabaseClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);
      addTearDown(client.dispose);

      expect(container.read(authServiceProvider), isA<SupabaseAuthService>());
    });
  });
}
