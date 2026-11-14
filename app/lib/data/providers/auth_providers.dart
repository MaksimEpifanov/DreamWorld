import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/mock_auth_service.dart';
import '../services/supabase_auth_service.dart';

final Provider<SupabaseClient> supabaseClientProvider =
    Provider<SupabaseClient>((Ref ref) => Supabase.instance.client);

final Provider<AuthService> authServiceProvider = Provider<AuthService>((
  Ref ref,
) {
  try {
    return SupabaseAuthService(ref.watch(supabaseClientProvider));
  } on AssertionError {
    return MockAuthService();
  }
});

/// Статус аутентификации.
enum AuthStatus {
  /// Сессия ещё восстанавливается — экран сплэша.
  unknown,

  /// Пользователь не вошёл.
  unauthenticated,

  /// Пользователь вошёл.
  authenticated,
}

/// Состояние аутентификации.
class AuthState {
  const AuthState({required this.status, this.user});

  const AuthState.unknown() : status = AuthStatus.unknown, user = null;

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null;

  final AuthStatus status;
  final AppUser? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnknown => status == AuthStatus.unknown;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState && status == other.status && user == other.user;

  @override
  int get hashCode => Object.hash(status, user);
}

/// Контроллер аутентификации: восстанавливает сессию и выполняет вход/выход.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    restore();
    return const AuthState.unknown();
  }

  AuthService get _service => ref.read(authServiceProvider);

  /// Восстанавливает сохранённую сессию при старте приложения.
  Future<void> restore() async {
    final AppUser? user = await _service.restoreSession();
    if (user == null) {
      state = const AuthState.unauthenticated();
    } else {
      state = AuthState(status: AuthStatus.authenticated, user: user);
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
    if (!result.emailConfirmationRequired) {
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
    } else {
      state = const AuthState.unauthenticated();
    }
    return result;
  }

  /// Входит в аккаунт. Бросает [AuthException] при ошибке.
  Future<void> login({required String email, required String password}) async {
    final AppUser user = await _service.login(email: email, password: password);
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  /// Завершает сессию.
  Future<void> logout() async {
    await _service.logout();
    state = const AuthState.unauthenticated();
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
