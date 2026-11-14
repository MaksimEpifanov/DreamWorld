import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import 'auth_service.dart';

/// Мок-реализация [AuthService] поверх shared_preferences.
///
/// Хранит список зарегистрированных аккаунтов и текущую сессию в виде JSON.
/// Пароли в мок-режиме сохраняются как есть — это допустимо для прототипа.
class MockAuthService implements AuthService {
  MockAuthService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Ключ списка зарегистрированных аккаунтов.
  static const String usersKey = 'auth_users';

  /// Ключ текущей сессии.
  static const String currentSessionKey = 'auth_current';

  final Uuid _uuid;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  List<Map<String, dynamic>> _readUsers(SharedPreferences prefs) {
    final String? raw = prefs.getString(usersKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (dynamic e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
        )
        .toList();
  }

  Future<void> _writeUsers(
    SharedPreferences prefs,
    List<Map<String, dynamic>> users,
  ) => prefs.setString(usersKey, jsonEncode(users));

  Future<void> _saveSession(SharedPreferences prefs, AppUser user) =>
      prefs.setString(currentSessionKey, jsonEncode(user.toJson()));

  String _normalize(String email) => email.trim().toLowerCase();

  @override
  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final SharedPreferences prefs = await _prefs;
    final List<Map<String, dynamic>> users = _readUsers(prefs);
    final String normalized = _normalize(email);

    final bool exists = users.any(
      (Map<String, dynamic> u) =>
          _normalize(u['email'] as String) == normalized,
    );
    if (exists) {
      throw const AuthException('Пользователь с таким email уже существует');
    }

    final AppUser user = AppUser(
      id: _uuid.v4(),
      email: email.trim(),
      name: name.trim(),
    );

    users.add(<String, dynamic>{...user.toJson(), 'password': password});
    await _writeUsers(prefs, users);
    await _saveSession(prefs, user);
    return RegistrationResult(user: user, emailConfirmationRequired: false);
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final SharedPreferences prefs = await _prefs;
    final List<Map<String, dynamic>> users = _readUsers(prefs);
    final String normalized = _normalize(email);

    final Map<String, dynamic>? account = users
        .cast<Map<String, dynamic>?>()
        .firstWhere(
          (Map<String, dynamic>? u) =>
              u != null && _normalize(u['email'] as String) == normalized,
          orElse: () => null,
        );

    if (account == null || account['password'] != password) {
      throw const AuthException('Неверный email или пароль');
    }

    final AppUser user = AppUser.fromJson(account);
    await _saveSession(prefs, user);
    return user;
  }

  @override
  Future<void> logout() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(currentSessionKey);
  }

  @override
  Future<AppUser?> restoreSession() async {
    final SharedPreferences prefs = await _prefs;
    final String? raw = prefs.getString(currentSessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final Map<String, dynamic> json = Map<String, dynamic>.from(
        jsonDecode(raw) as Map<dynamic, dynamic>,
      );
      return AppUser.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    throw const AuthException('Сброс пароля доступен после настройки сервера.');
  }

  @override
  Future<void> updatePassword({required String password}) async {
    throw const AuthException(
      'Изменение пароля доступно после настройки сервера.',
    );
  }
}
