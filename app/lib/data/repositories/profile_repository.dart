import '../models/profile.dart';

/// Источник профилей: текущий пользователь и каталог для подбора.
abstract interface class ProfileRepository {
  /// Текущий профиль (null, пока не создан).
  Future<Profile?> getCurrentProfile();

  /// Поток текущего профиля: первый элемент — текущее состояние.
  Stream<Profile?> watchCurrentProfile();

  /// Профиль по идентификатору.
  Future<Profile?> getProfileById(String id);

  /// Каталог профилей для подбора (без [excludeUserId]).
  Future<List<Profile>> getDiscoveryProfiles({
    int limit = 20,
    String? excludeUserId,
  });

  /// Поток каталога профилей.
  Stream<List<Profile>> watchDiscoveryProfiles({int limit = 20});

  /// Создание или обновление профиля.
  Future<void> saveProfile(Profile profile);

  /// Поиск анкет по публичному ID пользователя (уже нормализованному).
  ///
  /// Возвращает пустой список, если никто не найден.
  Future<List<Profile>> findByUserCode(String normalizedCode);

  /// Создан ли профиль текущего пользователя (не демо-заготовка).
  Future<bool> hasSavedProfileAsync();

  /// Освобождение ресурсов (потоки).
  void dispose();
}
