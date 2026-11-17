import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_bootstrap.dart';
import '../services/mock_auth_service.dart';

/// Сервис аутентификации: Firebase, если проект настроен, иначе мок-режим.
final Provider<AuthService> authServiceProvider = Provider<AuthService>((
  Ref ref,
) {
  if (isFirebaseInitialized) {
    return FirebaseAuthService(firebase.FirebaseAuth.instance);
  }
  return MockAuthService();
});

/// Статус аутентификации.
enum AuthStatus {
  /// Сессия ещё восстанавливается — экран сплэша.
  unknown,

  /// Пользователь не вошёл.
  unauthenticated,

  /// Аккаунт создан, но почта ещё не подтверждена.
  awaitingEmailVerification,

  /// Пользователь вошёл.
  authenticated,
}

/// Состояние аутентификации.
class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.email,
    this.pendingEmailVerification = false,
  });

  const AuthState.unknown()
    : status = AuthStatus.unknown,
      user = null,
      email = null,
      pendingEmailVerification = false;

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null,
      email = null,
      pendingEmailVerification = false;

  const AuthState.awaitingEmailVerification(String this.email)
    : status = AuthStatus.awaitingEmailVerification,
      user = null,
      pendingEmailVerification = true;

  final AuthStatus status;
  final AppUser? user;

  /// Email аккаунта, ожидающего подтверждения.
  final String? email;

  /// Пользователь вошёл, но почта ещё не подтверждена (вошёл без письма).
  final bool pendingEmailVerification;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnknown => status == AuthStatus.unknown;
  bool get isAwaitingEmailVerification =>
      status == AuthStatus.awaitingEmailVerification;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          status == other.status &&
          user == other.user &&
          email == other.email &&
          pendingEmailVerification == other.pendingEmailVerification;

  @override
  int get hashCode =>
      Object.hash(status, user, email, pendingEmailVerification);
}

/// Контроллер аутентификации: восстанавливает сессию и выполняет вход/выход.
class AuthController extends Notifier<AuthState> {
  static const String _skipVerificationKey = 'skip_email_verification_email';

  @override
  AuthState build() {
    restore();
    return const AuthState.unknown();
  }

  AuthService get _service => ref.read(authServiceProvider);

  Future<String?> _skippedVerificationEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_skipVerificationKey);
  }

  Future<void> _rememberSkippedVerification(String? email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (email == null || email.isEmpty) {
      await prefs.remove(_skipVerificationKey);
      return;
    }
    await prefs.setString(_skipVerificationKey, email);
  }

  AuthState? _stateWithoutVerification(String? email) {
    if (email == null || email.isEmpty) return null;
    final AppUser? account = _service.currentAccount();
    if (account == null) return null;
    return AuthState(
      status: AuthStatus.authenticated,
      user: account,
      email: account.email,
      pendingEmailVerification: true,
    );
  }

  /// Восстанавливает сохранённую сессию при старте приложения.
  Future<void> restore() async {
    try {
      final AppUser? user = await _service.restoreSession();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return;
      }
      final String? pendingEmail = await _service.pendingVerificationEmail();
      if (pendingEmail != null) {
        final String? skipped = await _skippedVerificationEmail();
        if (skipped == pendingEmail) {
          final AuthState? withoutVerification = _stateWithoutVerification(
            pendingEmail,
          );
          if (withoutVerification != null) {
            state = withoutVerification;
            return;
          }
        }
        state = AuthState.awaitingEmailVerification(pendingEmail);
        return;
      }
      state = const AuthState.unauthenticated();
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Регистрирует нового пользователя. Бросает [AuthException] при ошибке.
  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final RegistrationResult result = await _service.register(
      email: email,
      password: password,
      name: name,
    );
    if (result.emailConfirmationRequired) {
      state = AuthState.awaitingEmailVerification(result.user.email);
    } else {
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
    }
    return result;
  }

  /// Входит в аккаунт. Бросает [AuthException] при ошибке.
  Future<void> login({required String email, required String password}) async {
    try {
      final AppUser user = await _service.login(
        email: email,
        password: password,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on EmailNotVerifiedException catch (error) {
      final String? skipped = await _skippedVerificationEmail();
      if (skipped == error.email) {
        final AuthState? withoutVerification = _stateWithoutVerification(
          error.email,
        );
        if (withoutVerification != null) {
          state = withoutVerification;
          return;
        }
      }
      state = AuthState.awaitingEmailVerification(error.email);
      rethrow;
    }
  }

  /// Завершает сессию.
  Future<void> logout() async {
    await _service.logout();
    await _rememberSkippedVerification(null);
    state = const AuthState.unauthenticated();
  }

  /// Повторно отправляет письмо с подтверждением почты.
  Future<void> resendVerificationEmail() => _service.resendVerificationEmail();

  /// Пускает в приложение без подтверждения почты.
  ///
  /// Нужно, когда письмо не доходит (например, mail.ru часто его блокирует).
  Future<void> continueWithoutVerification() async {
    final AppUser? user = _service.currentAccount();
    if (user == null) {
      throw const AuthException('Сессия истекла. Войдите в аккаунт заново.');
    }
    await _rememberSkippedVerification(user.email);
    state = AuthState(
      status: AuthStatus.authenticated,
      user: user,
      email: user.email,
      pendingEmailVerification: true,
    );
  }

  /// Проверяет, подтверждена ли почта, и открывает доступ к приложению.
  Future<void> confirmEmailVerified() async {
    final AppUser? user = await _service.reloadVerifiedUser();
    if (user == null) {
      throw const AuthException(
        'Почта ещё не подтверждена. Проверьте «Входящие» и «Спам», затем нажмите снова.',
      );
    }
    await _rememberSkippedVerification(null);
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> sendPasswordReset({required String email}) =>
      _service.sendPasswordReset(email: email);

  Future<void> updatePassword({required String password}) async {
    await _service.updatePassword(password: password);
    final AppUser? user = await _service.restoreSession();
    state = user == null
        ? const AuthState.unauthenticated()
        : AuthState(status: AuthStatus.authenticated, user: user);
  }
}

/// Провайдер состояния аутентификации.
final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Текущий пользователь-аккаунт (или `null`, если не вошёл).
final Provider<AppUser?> currentUserFromAuthProvider = Provider<AppUser?>(
  (Ref ref) => ref.watch(authControllerProvider).user,
);
