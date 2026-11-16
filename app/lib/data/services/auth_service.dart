import '../models/app_user.dart';

/// Ошибка аутентификации с человекочитаемым сообщением для UI.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Аккаунт существует, но почта ещё не подтверждена письмом.
class EmailNotVerifiedException extends AuthException {
  const EmailNotVerifiedException(this.email)
    : super(
        'Подтвердите почту: перейдите по ссылке из письма, затем вернитесь в приложение.',
      );

  final String email;
}

/// Абстракция сервиса аутентификации.
abstract interface class AuthService {
  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String name,
  });

  /// Входит в существующий аккаунт и открывает сессию.
  ///
  /// Бросает [EmailNotVerifiedException], если почта ещё не подтверждена.
  Future<AppUser> login({required String email, required String password});

  /// Завершает текущую сессию.
  Future<void> logout();

  /// Восстанавливает сохранённую сессию или возвращает `null`.
  Future<AppUser?> restoreSession();

  /// Текущий аккаунт без проверки подтверждения почты (или `null`).
  AppUser? currentAccount();

  /// Email аккаунта, ожидающего подтверждения почты, иначе `null`.
  Future<String?> pendingVerificationEmail();

  /// Повторно отправляет письмо с подтверждением почты.
  Future<void> resendVerificationEmail();

  /// Перепроверяет подтверждение почты и возвращает пользователя.
  ///
  /// `null`, если почта ещё не подтверждена.
  Future<AppUser?> reloadVerifiedUser();

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
