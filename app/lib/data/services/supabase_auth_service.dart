import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../models/app_user.dart';
import 'auth_service.dart';
import 'supabase_auth_config.dart';

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  String get _redirectUrl =>
      kIsWeb ? webAuthRedirectUrl : mobileAuthRedirectUrl;

  String get _passwordRecoveryRedirectUrl => kIsWeb
      ? webPasswordRecoveryRedirectUrl
      : mobilePasswordRecoveryRedirectUrl;

  AppUser _mapUser(User user) => AppUser(
    id: user.id,
    email: user.email ?? '',
    name: user.userMetadata?['name'] as String? ?? '',
  );

  @override
  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: <String, dynamic>{'name': name.trim()},
        emailRedirectTo: _redirectUrl,
      );
      final User? user = response.user;
      if (user == null) {
        throw const AuthException(
          'Не удалось создать аккаунт. Повторите попытку.',
        );
      }
      return RegistrationResult(
        user: _mapUser(user),
        emailConfirmationRequired: response.session == null,
      );
    } on AuthApiException catch (error) {
      throw AuthException(_messageFor(error));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Не удалось связаться с сервером. Попробуйте ещё раз.',
      );
    }
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = response.user;
      if (user == null) throw const AuthException('Неверный email или пароль.');
      return _mapUser(user);
    } on AuthApiException catch (error) {
      throw AuthException(_messageFor(error));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Не удалось связаться с сервером. Попробуйте ещё раз.',
      );
    }
  }

  @override
  Future<void> logout() => _client.auth.signOut();

  @override
  Future<AppUser?> restoreSession() async {
    final User? user = _client.auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: _passwordRecoveryRedirectUrl,
      );
    } on AuthApiException catch (error) {
      throw AuthException(_messageFor(error));
    } catch (_) {
      throw const AuthException(
        'Не удалось отправить письмо. Попробуйте ещё раз.',
      );
    }
  }

  @override
  Future<void> updatePassword({required String password}) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: password));
    } on AuthApiException catch (error) {
      throw AuthException(_messageFor(error));
    } catch (_) {
      throw const AuthException(
        'Не удалось изменить пароль. Попробуйте ещё раз.',
      );
    }
  }

  String _messageFor(AuthApiException error) {
    final String message = error.message.toLowerCase();
    if (message.contains('already registered')) {
      return 'Аккаунт с таким email уже существует.';
    }
    if (message.contains('email not confirmed')) {
      return 'Подтвердите email по ссылке из письма.';
    }
    if (message.contains('invalid login credentials')) {
      return 'Неверный email или пароль.';
    }
    if (message.contains('password')) {
      return 'Пароль не соответствует требованиям.';
    }
    return 'Не удалось выполнить запрос. Проверьте данные и попробуйте ещё раз.';
  }
}
