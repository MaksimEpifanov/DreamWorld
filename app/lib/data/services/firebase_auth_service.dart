import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'auth_service.dart';

/// Аутентификация через Firebase: вход по email и паролю, подтверждение
/// почты письмом Google и восстановление пароля.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._auth);

  final firebase.FirebaseAuth _auth;

  AppUser _mapUser(firebase.User user) =>
      AppUser(id: user.uid, email: user.email ?? '', name: _displayName(user));

  String _displayName(firebase.User user) {
    final String? name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final String email = user.email ?? '';
    final int at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  @override
  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final firebase.UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 25));
      final firebase.User? user = credential.user;
      if (user == null) {
        throw const AuthException(
          'Не удалось создать аккаунт. Попробуйте ещё раз.',
        );
      }
      final String displayName = name.trim();
      if (displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }
      await _sendVerification(user);
      return RegistrationResult(
        user: _mapUser(user),
        emailConfirmationRequired: true,
      );
    } on TimeoutException {
      throw const AuthException(
        'Нет соединения с сервером. Проверьте интернет и попробуйте снова.',
      );
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthException(_message(error));
    }
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final firebase.UserCredential credential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password)
          .timeout(const Duration(seconds: 25));
      final firebase.User? user = credential.user;
      if (user == null) {
        throw const AuthException('Не удалось войти. Попробуйте ещё раз.');
      }
      await user.reload().timeout(const Duration(seconds: 15));
      final firebase.User? fresh = _auth.currentUser;
      if (fresh == null) {
        throw const AuthException('Не удалось войти. Попробуйте ещё раз.');
      }
      if (!fresh.emailVerified) {
        throw EmailNotVerifiedException(fresh.email ?? email.trim());
      }
      return _mapUser(fresh);
    } on TimeoutException {
      throw const AuthException(
        'Нет соединения с сервером. Проверьте интернет и попробуйте снова.',
      );
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthException(_message(error));
    }
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<AppUser?> restoreSession() async {
    final firebase.User? user = _auth.currentUser;
    if (user == null) return null;
    try {
      await user.reload().timeout(const Duration(seconds: 6));
    } catch (error) {
      debugPrint('Не удалось обновить сессию Firebase: $error');
    }
    final firebase.User? fresh = _auth.currentUser;
    if (fresh == null || !fresh.emailVerified) return null;
    return _mapUser(fresh);
  }

  @override
  Future<String?> pendingVerificationEmail() async {
    final firebase.User? user = _auth.currentUser;
    if (user == null || user.emailVerified) return null;
    return user.email;
  }

  @override
  Future<void> resendVerificationEmail() async {
    final firebase.User? user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(
        'Сессия истекла. Войдите в аккаунт, чтобы отправить письмо снова.',
      );
    }
    if (user.emailVerified) return;
    try {
      await _sendVerification(user);
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthException(_message(error));
    }
  }

  @override
  Future<AppUser?> reloadVerifiedUser() async {
    final firebase.User? user = _auth.currentUser;
    if (user == null) return null;
    await user.reload().timeout(const Duration(seconds: 15));
    final firebase.User? fresh = _auth.currentUser;
    if (fresh == null || !fresh.emailVerified) return null;
    return _mapUser(fresh);
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on firebase.FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') return;
      throw AuthException(_message(error));
    }
  }

  @override
  Future<void> updatePassword({required String password}) async {
    final firebase.User? user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(
        'Сессия истекла. Запросите новую ссылку для сброса пароля.',
      );
    }
    try {
      await user.updatePassword(password);
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthException(_message(error));
    }
  }

  @override
  AppUser? currentAccount() {
    final firebase.User? user = _auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  Future<void> _sendVerification(firebase.User user) async {
    try {
      await user.sendEmailVerification().timeout(const Duration(seconds: 15));
    } catch (error) {
      debugPrint('Письмо подтверждения не отправлено: $error');
    }
  }

  String _message(firebase.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Некорректный email.';
      case 'email-already-in-use':
        return 'Аккаунт с таким email уже существует. Войдите или восстановите пароль.';
      case 'weak-password':
        return 'Слишком простой пароль. Придумайте пароль надёжнее.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неверный email или пароль.';
      case 'user-disabled':
        return 'Этот аккаунт заблокирован.';
      case 'too-many-requests':
        return 'Слишком много попыток. Подождите несколько минут и попробуйте снова.';
      case 'network-request-failed':
        return 'Нет соединения с сервером. Проверьте интернет и попробуйте снова.';
      case 'operation-not-allowed':
        return 'Вход по email временно отключён в настройках проекта Firebase.';
      case 'requires-recent-login':
        return 'Войдите в аккаунт заново, чтобы изменить пароль.';
      default:
        return 'Не удалось выполнить действие. Попробуйте ещё раз.';
    }
  }
}
