/// Публичный идентификатор пользователя вида `DW-7K4M-2QXV`.
///
/// Строится детерминированно из внутреннего идентификатора (Firebase UID или
/// мок-идентификатора), поэтому не требует отдельного хранения: код всегда
/// одинаковый на сайте и в APK, даже после переустановки приложения.
class UserCode {
  const UserCode._();

  /// Префикс, по которому узнаётся код пользователя.
  static const String prefix = 'DW-';

  /// Количество значимых символов после префикса.
  static const int length = 8;

  /// Алфавит без похожих символов (0/O, 1/I), чтобы код было легко продиктовать.
  static const String _alphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';

  /// Первое и второе «зёрна» для двух независимых частей кода.
  static const int _firstSeed = 7;
  static const int _secondSeed = 5381;

  /// Код пользователя по его внутреннему идентификатору.
  static String fromUserId(String userId) {
    if (userId.isEmpty) return '';
    final int first = _hash(userId, _firstSeed);
    final int second = _hash('$userId#dreem', _secondSeed);
    return '$prefix${_encode(first, 4)}-${_encode(second, 4)}';
  }

  /// Оставляет только значимые символы кода в верхнем регистре.
  ///
  /// Позволяет искать код, введённый как `dw 7k4m 2qxv` или `DW-7K4M-2QXV`.
  static String normalize(String input) {
    final String upper = input.toUpperCase();
    if (upper.startsWith('DW') &&
        _significant(upper.substring(2)).length == length) {
      return _significant(upper.substring(2));
    }
    return _significant(upper);
  }

  static String _significant(String value) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final String char = value[i];
      if (_alphabet.contains(char)) buffer.write(char);
    }
    return buffer.toString();
  }

  /// Полный ли код введён (8 значимых символов).
  static bool isComplete(String input) => normalize(input).length == length;

  /// Совпадает ли код [query] с кодом пользователя [userId].
  static bool matches(String userId, String query) {
    final String normalized = normalize(query);
    if (normalized.isEmpty) return false;
    return normalize(fromUserId(userId)) == normalized;
  }

  static int _hash(String value, int seed) {
    int hash = seed;
    for (int i = 0; i < value.length; i++) {
      // Ограничение под 2^31 сохраняет одинаковый результат на сайте и в APK:
      // на web числа не должны выходить за пределы точности JavaScript.
      hash = (hash * 31 + value.codeUnitAt(i)) % 0x7FFFFFFF;
    }
    return hash;
  }

  static String _encode(int value, int size) {
    int rest = value;
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < size; i++) {
      buffer.write(_alphabet[rest % _alphabet.length]);
      rest ~/= _alphabet.length;
    }
    return buffer.toString();
  }
}
