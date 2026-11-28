import 'translation_service.dart';

/// Мок-переводчик: офлайн, помечает текст языком назначения.
class MockTranslationService implements TranslationService {
  const MockTranslationService();

  @override
  List<String> get supportedLanguages => const <String>[
    'ru',
    'en',
    'es',
    'de',
    'fr',
    'it',
    'pt',
    'zh',
    'ja',
    'ko',
    'ar',
    'tr',
    'hi',
    'pl',
    'uk',
    'kk',
    'uz',
  ];

  @override
  String get defaultTargetLanguage => 'ru';

  @override
  Future<String> translate(
    String text, {
    required String fromLang,
    required String toLang,
  }) async {
    if (text.trim().isEmpty || fromLang == toLang) {
      return text;
    }
    if (!supportedLanguages.contains(toLang)) {
      return text;
    }
    // TODO(A7): заменить на реальный переводчик.
    return '[$toLang] $text';
  }
}
