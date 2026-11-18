import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/map_spot.dart';
import '../models/planet.dart';
import '../models/planet_event.dart';
import '../models/planet_news.dart';
import '../models/profile.dart';
import '../repositories/firestore_map_repository.dart';
import '../repositories/firestore_planet_event_repository.dart';
import '../repositories/map_repository.dart';
import '../repositories/mock_map_repository.dart';
import '../repositories/mock_news_repository.dart';
import '../repositories/mock_planet_event_repository.dart';
import '../repositories/mock_planet_repository.dart';
import '../repositories/news_repository.dart';
import '../repositories/planet_event_repository.dart';
import '../repositories/planet_repository.dart';
import '../repositories/profile_repository.dart';
import '../services/firebase_bootstrap.dart';
import 'app_providers.dart';
import 'auth_providers.dart';

/// Репозиторий планет-сообществ.
final Provider<PlanetRepository> planetRepositoryProvider =
    Provider<PlanetRepository>((Ref ref) => const MockPlanetRepository());

/// Репозиторий отметок на карте планет.
///
/// В рабочей версии отметки хранятся в Firestore и общие для всех участников
/// планеты, в мок-режиме — в памяти.
final Provider<MapRepository> mapRepositoryProvider = Provider<MapRepository>((
  Ref ref,
) {
  final String currentUserId = ref.watch(currentUserIdProvider);
  if (isFirebaseInitialized) {
    final FirestoreMapRepository repository = FirestoreMapRepository(
      currentUserId: currentUserId,
    );
    ref.onDispose(repository.dispose);
    return repository;
  }
  final MockMapRepository repository = MockMapRepository(
    currentUserId: currentUserId,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// Репозиторий новостной ленты планет.
final Provider<NewsRepository> newsRepositoryProvider =
    Provider<NewsRepository>((Ref ref) => const MockNewsRepository());

/// Репозиторий событий планеты.
///
/// В рабочей версии события хранятся в Firestore и общие для всех участников,
/// в мок-режиме — в памяти.
final Provider<PlanetEventRepository> planetEventRepositoryProvider =
    Provider<PlanetEventRepository>((Ref ref) {
      final String currentUserId = ref.watch(currentUserIdProvider);
      if (isFirebaseInitialized) {
        final FirestorePlanetEventRepository repository =
            FirestorePlanetEventRepository(currentUserId: currentUserId);
        ref.onDispose(repository.dispose);
        return repository;
      }
      final MockPlanetEventRepository repository = MockPlanetEventRepository(
        currentUserId: currentUserId,
      );
      ref.onDispose(repository.dispose);
      return repository;
    });

/// Каталог планет.
///
/// В рабочей версии число участников берётся из реальных анкет, поэтому
/// под планетами не показываются выдуманные значения.
final Provider<List<Planet>> planetsProvider = Provider<List<Planet>>((
  Ref ref,
) {
  final List<Planet> base = ref.watch(planetRepositoryProvider).getPlanets();
  if (!isFirebaseInitialized) return base;
  return base
      .map(
        (Planet planet) => planet.copyWith(
          memberCount: ref.watch(planetMemberCountProvider(planet.id)),
        ),
      )
      .toList(growable: false);
});

/// Избранные планеты на главной (до 7).
///
/// Сначала планеты, подходящие по интересам профиля (если они есть), затем
/// список дополняется остальными планетами каталога — чтобы на главной
/// всегда было до 7 орбит.
final Provider<List<Planet>> featuredPlanetsProvider = Provider<List<Planet>>((
  Ref ref,
) {
  const int featuredCount = 7;
  final List<Planet> all = ref.watch(planetsProvider);
  final List<String> interests =
      ref.watch(currentProfileProvider).valueOrNull?.interestNames ??
      const <String>[];

  final List<Planet> matched = interests.isEmpty
      ? <Planet>[]
      : all
            .where((Planet planet) => planet.keywords.any(interests.contains))
            .toList(growable: false);

  final List<Planet> result = <Planet>[...matched];
  for (final Planet planet in all) {
    if (result.length >= featuredCount) break;
    if (!result.any((Planet p) => p.id == planet.id)) {
      result.add(planet);
    }
  }
  return result.take(featuredCount).toList(growable: false);
});

/// Планеты «других интересов» — всё, что не попало в избранные (до 4).
final Provider<List<Planet>> otherPlanetsProvider = Provider<List<Planet>>((
  Ref ref,
) {
  final List<Planet> all = ref.watch(planetsProvider);
  final Set<String> featured = ref
      .watch(featuredPlanetsProvider)
      .map((Planet planet) => planet.id)
      .toSet();
  return all
      .where((Planet planet) => !featured.contains(planet.id))
      .toList(growable: false);
});

/// Планета по идентификатору.
final ProviderFamily<Planet?, String> planetByIdProvider =
    Provider.family<Planet?, String>(
      (Ref ref, String id) => ref.watch(planetRepositoryProvider).byId(id),
    );

/// Все анкеты сообщества: реальные пользователи Firebase (включая текущего)
/// или демо-подбор в мок-режиме.
final Provider<AsyncValue<List<Profile>>> communityProfilesProvider =
    Provider<AsyncValue<List<Profile>>>((Ref ref) {
      final AsyncValue<List<Profile>> others = ref.watch(
        discoveryProfilesProvider,
      );
      final Profile? me = ref.watch(currentProfileProvider).valueOrNull;
      return others.whenData((List<Profile> list) => <Profile>[?me, ...list]);
    });

/// Сколько участников реально вступило в планету.
///
/// В мок-режиме остаются демонстрационные числа из каталога, в рабочей
/// версии — фактическое количество анкет с этой планетой.
final ProviderFamily<int, String> planetMemberCountProvider =
    Provider.family<int, String>((Ref ref, String id) {
      if (!isFirebaseInitialized) {
        return ref.watch(planetByIdProvider(id))?.memberCount ?? 0;
      }
      final List<Profile> all =
          ref.watch(communityProfilesProvider).valueOrNull ?? const <Profile>[];
      return all
          .where((Profile profile) => profile.joinedPlanetIds.contains(id))
          .length;
    });

/// Участники планеты.
///
/// В рабочей версии — только реальные пользователи, которые вступили в неё.
/// В мок-режиме остаётся демонстрационная подборка по интересам, чтобы
/// приложение было непустым без бэкенда.
final ProviderFamily<AsyncValue<List<Profile>>, String> planetMembersProvider =
    Provider.family<AsyncValue<List<Profile>>, String>((Ref ref, String id) {
      final Planet? planet = ref.watch(planetByIdProvider(id));

      if (planet == null) {
        return const AsyncValue<List<Profile>>.data(<Profile>[]);
      }

      if (isFirebaseInitialized) {
        return ref
            .watch(communityProfilesProvider)
            .whenData(
              (List<Profile> all) => all
                  .where(
                    (Profile profile) => profile.joinedPlanetIds.contains(id),
                  )
                  .toList(growable: false),
            );
      }

      final AsyncValue<List<Profile>> profiles = ref.watch(
        discoveryProfilesProvider,
      );
      return profiles.whenData((List<Profile> all) {
        final List<Profile> matched = all
            .where(
              (Profile profile) =>
                  profile.interestNames.any(planet.keywords.contains),
            )
            .toList(growable: false);
        return matched.isEmpty ? all : matched;
      });
    });

/// Вступление в планету и выход из неё.
///
/// Список планет хранится в анкете пользователя (`joinedPlanetIds`), поэтому
/// он общий для сайта и приложения и не требует отдельного бэкенда.
class PlanetMembershipController {
  PlanetMembershipController(this._ref);

  final Ref _ref;

  /// Вступает в планету или выходит из неё. Возвращает новое состояние.
  Future<bool> toggle(String planetId) async {
    final ProfileRepository repository = _ref.read(profileRepositoryProvider);
    Profile? me =
        await repository.getCurrentProfile() ??
        _ref.read(currentProfileProvider).valueOrNull;
    // Если анкеты ещё нет (новый аккаунт без заполнения профиля), создаём её
    // из аккаунта, чтобы вступление работало сразу.
    if (me == null) {
      final AppUser? account = _ref.read(currentUserFromAuthProvider);
      final String accountName = account?.name.trim() ?? '';
      me = Profile(
        id: _ref.read(currentUserIdProvider),
        name: accountName.isEmpty ? 'Пользователь' : accountName,
        age: 18,
        createdAt: DateTime.now(),
      );
    }
    final Set<String> joined = me.joinedPlanetIds.toSet();
    final bool nowJoined = !joined.remove(planetId);
    if (nowJoined) joined.add(planetId);
    await repository.saveProfile(
      me.copyWith(joinedPlanetIds: joined.toList(growable: false)),
    );
    // Обновляем поток анкеты, чтобы кнопка сразу стала «Вы уже присоединились».
    _ref.invalidate(currentProfileProvider);
    return nowJoined;
  }
}

/// Контроллер вступления в планеты.
final Provider<PlanetMembershipController> planetMembershipControllerProvider =
    Provider<PlanetMembershipController>(
      (Ref ref) => PlanetMembershipController(ref),
    );

/// Отметки на карте планеты.
///
/// В рабочей версии — живой поток из Firestore: добавленную одним участником
/// отметку сразу видят остальные. В мок-режиме — сгенерированная карта.
final StreamProviderFamily<List<MapSpot>, String> planetMapSpotsProvider =
    StreamProvider.family<List<MapSpot>, String>((Ref ref, String id) {
      final Planet? planet = ref.watch(planetByIdProvider(id));
      if (planet == null) {
        return Stream<List<MapSpot>>.value(const <MapSpot>[]);
      }
      return ref.watch(mapRepositoryProvider).watchSpots(planet);
    });

/// События планеты.
///
/// В рабочей версии — живой поток из Firestore: созданное одним участником
/// событие и поданные заявки сразу видят остальные. В мок-режиме — память.
final StreamProviderFamily<List<PlanetEvent>, String> planetEventsProvider =
    StreamProvider.family<List<PlanetEvent>, String>((Ref ref, String id) {
      final Planet? planet = ref.watch(planetByIdProvider(id));
      if (planet == null) {
        return Stream<List<PlanetEvent>>.value(const <PlanetEvent>[]);
      }
      return ref.watch(planetEventRepositoryProvider).watchEvents(planet);
    });

/// Лента новостей планеты с обновлением раз в час.
///
/// Первый выпуск отдаётся сразу, затем лента пересобирается каждый час.
final StreamProviderFamily<List<PlanetNewsItem>, String> planetNewsProvider =
    StreamProvider.family<List<PlanetNewsItem>, String>((Ref ref, String id) {
      final Planet? planet = ref.watch(planetByIdProvider(id));
      if (planet == null) {
        return Stream<List<PlanetNewsItem>>.value(const <PlanetNewsItem>[]);
      }

      final NewsRepository repository = ref.watch(newsRepositoryProvider);
      return _hourlyNews(repository, planet);
    });

/// Бесконечный поток новостей: сразу первая порция, далее раз в час.
///
/// Поток отменяет таймер при закрытии подписки (например, при уходе с
/// экрана), поэтому не оставляет «висящих» таймеров.
Stream<List<PlanetNewsItem>> _hourlyNews(
  NewsRepository repository,
  Planet planet,
) {
  StreamController<List<PlanetNewsItem>>? controller;
  Timer? timer;

  void emit() =>
      controller?.add(repository.newsFor(planet, now: DateTime.now()));

  controller = StreamController<List<PlanetNewsItem>>(
    onListen: () {
      emit();
      timer = Timer.periodic(const Duration(hours: 1), (_) => emit());
    },
    onCancel: () {
      timer?.cancel();
      timer = null;
    },
  );

  return controller.stream;
}
