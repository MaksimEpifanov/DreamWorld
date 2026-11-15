import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/interest.dart';
import '../models/profile.dart';
import '../services/realtime_service.dart';
import '../services/user_code.dart';
import 'profile_repository.dart';

/// Профили в памяти с сид-данными для демо.
///
/// Текущий профиль (`id == currentUserId`) дополнительно сохраняется
/// в `shared_preferences` (ключ [savedProfileKey]) и восстанавливается
/// при создании репозитория — профиль не теряется между перезапусками.
class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({
    this.currentUserId = defaultCurrentUserId,
    this.realtime,
  }) {
    for (final Profile profile in seedProfiles) {
      _profiles[profile.id] = profile;
    }
    _restoreFuture = _restore();
  }

  /// Идентификатор текущего пользователя в мок-режиме.
  static const String defaultCurrentUserId = 'me';

  /// Ключ `shared_preferences` с сохранённым профилем текущего пользователя.
  static const String savedProfileKey = 'saved_profile_me';

  /// Демо-профили: текущий пользователь и кандидаты для подбора.
  static const List<Profile> seedProfiles = <Profile>[
    Profile(
      id: defaultCurrentUserId,
      name: 'Ты',
      age: 26,
      city: 'Москва',
      country: 'Россия',
      bio: 'Ищу людей, с которыми интересно говорить обо всём.',
      interests: <Interest>[
        InterestCatalog.travel,
        InterestCatalog.tech,
        InterestCatalog.music,
        InterestCatalog.nature,
      ],
      goals: <String>['общение', 'дружба', 'путешествия'],
      values: <String>['честность', 'любознательность', 'свобода'],
      languages: <String>['ru', 'en'],
      relationshipGoal: RelationshipGoal.friendship,
    ),
    Profile(
      id: 'p_anna',
      name: 'Анна',
      age: 24,
      city: 'Санкт-Петербург',
      country: 'Россия',
      bio: 'Фотограф, люблю горы и долгие разговоры.',
      interests: <Interest>[
        InterestCatalog.travel,
        InterestCatalog.photography,
        InterestCatalog.nature,
        InterestCatalog.music,
      ],
      goals: <String>['путешествия', 'дружба'],
      values: <String>['честность', 'свобода'],
      languages: <String>['ru', 'en'],
      relationshipGoal: RelationshipGoal.friendship,
    ),
    Profile(
      id: 'p_leo',
      name: 'Leo',
      age: 29,
      city: 'Берлин',
      country: 'Германия',
      bio: 'Software engineer. Coffee and board games.',
      interests: <Interest>[
        InterestCatalog.tech,
        InterestCatalog.games,
        InterestCatalog.cinema,
        InterestCatalog.food,
      ],
      goals: <String>['общение', 'дружба'],
      values: <String>['любознательность', 'развитие'],
      languages: <String>['en', 'de'],
      relationshipGoal: RelationshipGoal.friendship,
    ),
    Profile(
      id: 'p_sofia',
      name: 'Sofía',
      age: 27,
      city: 'Барселона',
      country: 'Испания',
      bio: 'Diseñadora. Amo el arte y la música en vivo.',
      interests: <Interest>[
        InterestCatalog.art,
        InterestCatalog.music,
        InterestCatalog.travel,
        InterestCatalog.food,
      ],
      goals: <String>['путешествия', 'отношения'],
      values: <String>['творчество', 'свобода'],
      languages: <String>['es', 'en'],
      relationshipGoal: RelationshipGoal.dating,
    ),
    Profile(
      id: 'p_mia',
      name: 'Mia',
      age: 23,
      city: 'Токио',
      country: 'Япония',
      bio: 'ゲームと本が好きです。',
      interests: <Interest>[
        InterestCatalog.games,
        InterestCatalog.books,
        InterestCatalog.cinema,
        InterestCatalog.food,
      ],
      goals: <String>['общение'],
      values: <String>['доброта'],
      languages: <String>['ja', 'en'],
      relationshipGoal: RelationshipGoal.chat,
    ),
    Profile(
      id: 'p_dmitri',
      name: 'Дмитрий',
      age: 31,
      city: 'Казань',
      country: 'Россия',
      bio: 'Бегаю марафоны и готовлю рамэн.',
      interests: <Interest>[
        InterestCatalog.sport,
        InterestCatalog.fitness,
        InterestCatalog.food,
        InterestCatalog.nature,
      ],
      goals: <String>['дружба', 'спорт'],
      values: <String>['дисциплина', 'честность'],
      languages: <String>['ru', 'en'],
      relationshipGoal: RelationshipGoal.friendship,
    ),
  ];

  /// Идентификатор текущего пользователя.
  final String currentUserId;

  /// Опциональная шина реалтайм-событий.
  final RealtimeService? realtime;

  final Map<String, Profile> _profiles = <String, Profile>{};
  final StreamController<Profile?> _currentController =
      StreamController<Profile?>.broadcast();
  final StreamController<List<Profile>> _catalogController =
      StreamController<List<Profile>>.broadcast();

  late final Future<void> _restoreFuture;
  bool _hasSavedProfile = false;

  /// Восстановлен ли сохранённый профиль (после завершения загрузки из
  /// `shared_preferences`). Сид-профиль текущего пользователя не считается.
  bool get hasSavedProfile => _hasSavedProfile;

  /// Ждёт завершения восстановления и сообщает, был ли сохранённый профиль.
  @override
  Future<bool> hasSavedProfileAsync() async {
    await _restoreFuture;
    return _hasSavedProfile;
  }

  @override
  Future<List<Profile>> findByUserCode(String normalizedCode) async {
    if (normalizedCode.isEmpty) return const <Profile>[];
    await _restoreFuture;
    return _profiles.values
        .where(
          (Profile profile) => UserCode.matches(profile.id, normalizedCode),
        )
        .toList(growable: false);
  }

  String get _savedProfileKey => currentUserId == defaultCurrentUserId
      ? savedProfileKey
      : 'saved_profile_$currentUserId';

  Future<void> _restore() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_savedProfileKey);
      if (raw == null || raw.isEmpty) return;

      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;

      final Profile profile = Profile.fromJson(decoded);
      if (profile.id != currentUserId) return;

      _profiles[currentUserId] = profile;
      _hasSavedProfile = true;
    } catch (_) {
      // Битые данные или недоступное хранилище — оставляем сид-профиль.
    }
  }

  Future<void> _persistCurrentProfile(Profile profile) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedProfileKey, jsonEncode(profile.toJson()));
    } catch (_) {
      // Мок: сбой хранилища не должен ломать сохранение в памяти.
    }
  }

  @override
  Future<Profile?> getCurrentProfile() async {
    await _restoreFuture;
    return _profiles[currentUserId];
  }

  @override
  Stream<Profile?> watchCurrentProfile() async* {
    await _restoreFuture;
    yield _profiles[currentUserId];
    yield* _currentController.stream;
  }

  @override
  Future<Profile?> getProfileById(String id) async => _profiles[id];

  @override
  Future<List<Profile>> getDiscoveryProfiles({
    int limit = 20,
    String? excludeUserId,
  }) async {
    final String exclude = excludeUserId ?? currentUserId;
    return _profiles.values
        .where((Profile profile) => profile.id != exclude)
        .take(limit)
        .toList(growable: false);
  }

  @override
  Stream<List<Profile>> watchDiscoveryProfiles({int limit = 20}) async* {
    yield await getDiscoveryProfiles(limit: limit);
    yield* _catalogController.stream;
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    await _restoreFuture;
    _profiles[profile.id] = profile;
    _catalogController.add(List<Profile>.unmodifiable(_profiles.values));
    if (profile.id == currentUserId) {
      _hasSavedProfile = true;
      _currentController.add(profile);
      realtime?.emit(RealtimeEvent.profileUpdated(profile: profile));
      await _persistCurrentProfile(profile);
    }
  }

  @override
  void dispose() {
    _currentController.close();
    _catalogController.close();
  }
}
