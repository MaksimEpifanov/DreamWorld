bool _initialized = false;

bool get isFirebaseInitialized => false;

Future<void> initFirebaseIfConfigured() async {
  _initialized = false;
}
