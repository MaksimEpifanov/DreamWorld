class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static const bool isConfigured = false;

  static get currentPlatform => throw UnsupportedError(
    'Firebase disabled',
  );
}
