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

  /// Добавляет пользователя в контакты взаимно: и себе, и ему.
  ///
  /// Нужно, чтобы после добавления контакт появлялся у обоих пользователей.
  Future<void> addContactMutual(String otherId);

  /// Убирает пользователя из контактов взаимно: и у себя, и у него.
  Future<void> removeContactMutual(String otherId);

  /// Отправляет запрос в контакты: у себя помечает как исходящий, а у
  /// собеседника — как входящий, чтобы он мог принять или отклонить его.
  Future<void> sendContactRequest(String otherId);

  /// Принимает входящий запрос: добавляет контакт взаимно и убирает запрос.
  Future<void> acceptContactRequest(String otherId);

  /// Отклоняет входящий запрос: убирает его у себя и у отправителя.
  Future<void> declineContactRequest(String otherId);

  /// Отменяет собственный исходящий запрос.
  Future<void> cancelContactRequest(String otherId);

  /// Поиск анкет по публичному ID пользователя (уже нормализованному).
  ///
  /// Возвращает пустой список, если никто не найден.
  Future<List<Profile>> findByUserCode(String normalizedCode);

  /// Создан ли профиль текущего пользователя (не демо-заготовка).
  Future<bool> hasSavedProfileAsync();

  /// Освобождение ресурсов (потоки).
  void dispose();
}
