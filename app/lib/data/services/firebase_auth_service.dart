import '../models/app_user.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  @override
  Future<RegistrationResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    throw UnimplementedError('Firebase disabled');
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError('Firebase disabled');
  }

  @override
  Future<void> logout() async {
    throw UnimplementedError('Firebase disabled');
  }

  @override
  Future<AppUser?> restoreSession() async {
    return null;
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    throw UnimplementedError('Firebase disabled');
  }

  @override
  Future<void> updatePassword({required String password}) async {
    throw UnimplementedError('Firebase disabled');
  }

  AppUser? get currentUser => null;
}
