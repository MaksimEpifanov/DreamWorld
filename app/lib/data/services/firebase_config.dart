import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

/// Настройки проекта Firebase.
///
/// Значения берутся из консоли Firebase: «Настройки проекта → Ваши приложения».
/// Пока поля пустые, приложение работает в мок-режиме без сети.
class FirebaseConfig {
  const FirebaseConfig._();

  static const String projectId = 'dreamworld-34005';
  static const String apiKey = 'AIzaSyCui9XPyxkcQxITpTf3IQgBBRHGE8DdLuk';
  static const String authDomain = 'dreamworld-34005.firebaseapp.com';
  static const String storageBucket = 'dreamworld-34005.firebasestorage.app';
  static const String messagingSenderId = '49472563968';

  /// Ключ Android-приложения из `google-services.json`.
  static const String androidApiKey = 'AIzaSyB7Ry3SQHOLVehoBWhDGWmvqLN-lF5afzg';
  static const String androidAppId =
      '1:49472563968:android:20ea9d3e2ace247c64a1e5';
  static const String webAppId = '1:49472563968:web:382f86664a65c97364a1e5';
  static const String iosAppId = '';
  static const String iosBundleId = 'com.dreemworld.app.dreemWorld';

  /// Ключ reCAPTCHA v3 для Firebase App Check на Web.
  /// Оставь пустым, если App Check для Web ещё не настроен в Firebase Console.
  static const String webRecaptchaSiteKey = '';

  /// Настроен ли Firebase для текущей платформы.
  static bool get isConfigured => currentPlatform != null;

  /// Параметры Firebase для текущей платформы или `null`, если их нет.
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return null;
    }
  }

  static FirebaseOptions? get web =>
      _options(appId: webAppId, authDomain: authDomain);

  static FirebaseOptions? get android =>
      _options(appId: androidAppId, platformApiKey: androidApiKey);

  static FirebaseOptions? get ios =>
      _options(appId: iosAppId, iosBundleId: iosBundleId);

  static FirebaseOptions? _options({
    required String appId,
    String? authDomain,
    String? iosBundleId,
    String? platformApiKey,
  }) {
    final String key = platformApiKey ?? apiKey;
    if (key.isEmpty ||
        projectId.isEmpty ||
        messagingSenderId.isEmpty ||
        appId.isEmpty) {
      return null;
    }
    return FirebaseOptions(
      apiKey: key,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain?.isEmpty ?? true ? null : authDomain,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
      iosBundleId: iosBundleId,
    );
  }
}
