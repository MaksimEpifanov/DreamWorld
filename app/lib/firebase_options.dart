class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static const bool isConfigured = false;

  static Object get currentPlatform => throw UnsupportedError(
    'Firebase disabled',
  );
}
