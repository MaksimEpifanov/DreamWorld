import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_config.dart';

bool _isFirebaseInitialized = false;

/// Инициализирован ли Firebase в текущем запуске.
bool get isFirebaseInitialized => _isFirebaseInitialized;

/// Инициализирует Firebase, если в [FirebaseConfig] заданы параметры проекта.
///
/// Без параметров приложение продолжает работать в мок-режиме.
Future<void> initFirebaseIfConfigured() async {
  if (_isFirebaseInitialized) return;
  final FirebaseOptions? options = FirebaseConfig.currentPlatform;
  if (options == null) return;
  try {
    await Firebase.initializeApp(options: options);
    await _activateAppCheck();
    _isFirebaseInitialized = true;
  } catch (error) {
    _isFirebaseInitialized = false;
    debugPrint('Firebase не инициализирован: $error');
  }
}

Future<void> _activateAppCheck() async {
  try {
    final String webRecaptchaKey = FirebaseConfig.webRecaptchaSiteKey;
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestProvider(),
      providerWeb: kDebugMode
          ? ReCaptchaV3Provider(webRecaptchaKey.isEmpty ? 'debug' : webRecaptchaKey)
          : webRecaptchaKey.isEmpty
              ? null
              : ReCaptchaV3Provider(webRecaptchaKey),
    );
  } catch (error) {
    debugPrint('Firebase App Check не активирован: $error');
  }
}
