import '../models/app_user.dart';

/// Ошибка аутентификации с человекочитаемым сообщением для UI.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Абстракция сервиса аутентификации.
///
/// TODO(R2): заменить мок-реализацию на реальный бэкенд (Supabase Auth).
abstract interface class AuthService {
  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String name,
  });

  /// Входит в существующий аккаунт и открывает сессию.
  Future<AppUser> login({required String email, required String password});

  /// Завершает текущую сессию.
  Future<void> logout();

  /// Восстанавливает сохранённую сессию или возвращает `null`.
  Future<AppUser?> restoreSession();

  Future<void> sendPasswordReset({required String email});

  Future<void> updatePassword({required String password});
}

class RegistrationResult {
  const RegistrationResult({
    required this.user,
    required this.emailConfirmationRequired,
  });

  final AppUser user;
  final bool emailConfirmationRequired;
}
