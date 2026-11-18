import 'dart:async';

import '../models/planet.dart';
import '../models/planet_event.dart';
import 'planet_event_repository.dart';

/// Мок-репозиторий событий планеты: память без сети (демо-режим без Firebase).
///
/// Для каждой планеты детерминированно создаётся пара демонстрационных событий,
/// чтобы приложение было непустым без бэкенда. Созданные в сессии события и
/// заявки живут в памяти и сбрасываются при перезапуске.
class MockPlanetEventRepository implements PlanetEventRepository {
  MockPlanetEventRepository({this.currentUserId = ''});

  final String currentUserId;

  final Map<String, List<PlanetEvent>> _cache = <String, List<PlanetEvent>>{};
  final Map<String, StreamController<List<PlanetEvent>>> _controllers =
      <String, StreamController<List<PlanetEvent>>>{};

  @override
  Stream<List<PlanetEvent>> watchEvents(Planet planet) async* {
    _eventsFor(planet);
    yield _snapshot(planet.id);
    yield* _controller(planet.id).stream;
  }

  @override
  Future<void> addEvent(Planet planet, PlanetEvent event) async {
    _eventsFor(planet).insert(0, event);
    _emit(planet.id);
  }

  @override
  Future<void> apply(Planet planet, String eventId) async {
    _mutate(planet, eventId, (PlanetEvent event) {
      if (currentUserId.isEmpty || event.applicantIds.contains(currentUserId)) {
        return event;
      }
      return event.copyWith(
        applicantIds: <String>[...event.applicantIds, currentUserId],
      );
    });
  }

  @override
  Future<void> withdraw(Planet planet, String eventId) async {
    _mutate(planet, eventId, (PlanetEvent event) {
      return event.copyWith(
        applicantIds: event.applicantIds
            .where((String id) => id != currentUserId)
            .toList(growable: false),
      );
    });
  }

  @override
  Future<void> approve(Planet planet, String eventId, String userId) async {
    _mutate(planet, eventId, (PlanetEvent event) {
      return event.copyWith(
        applicantIds: event.applicantIds
            .where((String id) => id != userId)
            .toList(growable: false),
        participantIds: event.participantIds.contains(userId)
            ? event.participantIds
            : <String>[...event.participantIds, userId],
      );
    });
  }

  @override
  Future<void> decline(Planet planet, String eventId, String userId) async {
    _mutate(planet, eventId, (PlanetEvent event) {
      return event.copyWith(
        applicantIds: event.applicantIds
            .where((String id) => id != userId)
            .toList(growable: false),
        participantIds: event.participantIds
            .where((String id) => id != userId)
            .toList(growable: false),
      );
    });
  }

  @override
  Future<void> removeEvent(Planet planet, String eventId) async {
    _eventsFor(planet).removeWhere((PlanetEvent event) => event.id == eventId);
    _emit(planet.id);
  }

  @override
  void dispose() {
    for (final StreamController<List<PlanetEvent>> controller
        in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  void _mutate(
    Planet planet,
    String eventId,
    PlanetEvent Function(PlanetEvent event) transform,
  ) {
    final List<PlanetEvent> events = _eventsFor(planet);
    final int index = events.indexWhere((PlanetEvent event) => event.id == eventId);
    if (index < 0) return;
    events[index] = transform(events[index]);
    _emit(planet.id);
  }

  List<PlanetEvent> _eventsFor(Planet planet) => _cache.putIfAbsent(
    planet.id,
    () => List<PlanetEvent>.of(_demo(planet)),
  );

  List<PlanetEvent> _snapshot(String planetId) => List<PlanetEvent>.unmodifiable(
    _cache[planetId] ?? const <PlanetEvent>[],
  );

  StreamController<List<PlanetEvent>> _controller(String planetId) =>
      _controllers.putIfAbsent(
        planetId,
        () => StreamController<List<PlanetEvent>>.broadcast(),
      );

  void _emit(String planetId) {
    final StreamController<List<PlanetEvent>>? controller =
        _controllers[planetId];
    if (controller != null && !controller.isClosed) {
      controller.add(_snapshot(planetId));
    }
  }

  /// Демонстрационные события для мок-режима (в рабочей версии их нет).
  List<PlanetEvent> _demo(Planet planet) {
    final String keyword = planet.keywords.isEmpty
        ? planet.name
        : planet.keywords.first;
    final DateTime now = DateTime.now();
    final String date = _dateString(now.add(const Duration(days: 5)));
    return <PlanetEvent>[
      PlanetEvent(
        id: '${planet.id}_event_demo_1',
        planetId: planet.id,
        title: 'Совместная встреча: $keyword',
        description:
            'Собираемся вместе, чтобы познакомиться и обсудить общие планы. '
            'Берите хорошее настроение!',
        emoji: '🤝',
        authorId: '',
        authorName: 'Аня',
        createdAt: now.subtract(const Duration(hours: 3)).toIso8601String(),
        date: date,
        place: 'Центр города',
        seats: 6,
        participantIds: const <String>[],
      ),
      PlanetEvent(
        id: '${planet.id}_event_demo_2',
        planetId: planet.id,
        title: 'Поездка выходного дня',
        description:
            'Спонтанная вылазка на природу. Нужны люди с машиной и без — '
            'места найдутся для всех.',
        emoji: '🚗',
        authorId: '',
        authorName: 'Марк',
        createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
        date: _dateString(now.add(const Duration(days: 12))),
        place: 'Выезд из города',
        seats: 0,
        participantIds: const <String>[],
      ),
    ];
  }

  static String _dateString(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}
