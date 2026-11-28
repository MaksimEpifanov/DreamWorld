/// Абстракция автоперевода сообщений.
///
/// Отдельно от [AiService]: перевод может уходить на другой бэкенд.
abstract interface class TranslationService {
  /// Поддерживаемые языки (коды ISO 639-1).
  List<String> get supportedLanguages;

  /// Язык по умолчанию для автоперевода.
  String get defaultTargetLanguage;

  /// Переводит [text] с [fromLang] на [toLang].
  ///
  /// Если языки совпадают — возвращает исходный текст.
  Future<String> translate(
    String text, {
    required String fromLang,
    required String toLang,
  });
}

/// Названия поддерживаемых языков для UI.
const Map<String, String> kTranslationLanguageLabels = <String, String>{
  'ru': 'Русский',
  'en': 'English',
  'es': 'Español',
  'de': 'Deutsch',
  'fr': 'Français',
  'it': 'Italiano',
  'pt': 'Português',
  'zh': '中文',
  'ja': '日本語',
  'ko': '한국어',
  'ar': 'العربية',
  'tr': 'Türkçe',
  'hi': 'हिन्दी',
  'pl': 'Polski',
  'uk': 'Українська',
  'kk': 'Қазақша',
  'uz': 'Oʻzbekcha',
};
