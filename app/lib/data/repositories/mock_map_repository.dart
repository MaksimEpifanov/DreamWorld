import 'dart:async';

import '../models/map_spot.dart';
import '../models/planet.dart';
import 'map_repository.dart';

/// Мок-репозиторий отметок на карте планеты.
///
/// Отметки генерируются детерминированно из идентификатора планеты, поэтому
/// у каждой планеты своя стабильная «карта», но без ручного описания.
/// Добавленные в сессии отметки, комментарии и лайки живут в памяти и
/// сбрасываются при перезапуске — это только демо-режим без Firebase.
class MockMapRepository implements MapRepository {
  MockMapRepository({this.currentUserId = ''});

  final String currentUserId;

  final Map<String, List<MapSpot>> _cache = <String, List<MapSpot>>{};
  final Map<String, StreamController<List<MapSpot>>> _controllers =
      <String, StreamController<List<MapSpot>>>{};

  @override
  Stream<List<MapSpot>> watchSpots(Planet planet) async* {
    _spotsFor(planet);
    yield _snapshot(planet.id);
    yield* _controller(planet.id).stream;
  }

  @override
  Future<void> addSpot(Planet planet, MapSpot spot) async {
    _spotsFor(planet).insert(0, spot);
    _emit(planet.id);
  }

  @override
  Future<void> addComment(
    Planet planet,
    String spotId,
    MapComment comment,
  ) async {
    final List<MapSpot> spots = _spotsFor(planet);
    final int index = spots.indexWhere((MapSpot spot) => spot.id == spotId);
    if (index < 0) return;
    spots[index] = spots[index].copyWith(
      comments: <MapComment>[...spots[index].comments, comment],
    );
    _emit(planet.id);
  }

  @override
  Future<void> setLike(
    Planet planet,
    String spotId, {
    required bool liked,
  }) async {
    final List<MapSpot> spots = _spotsFor(planet);
    final int index = spots.indexWhere((MapSpot spot) => spot.id == spotId);
    if (index < 0) return;
    final MapSpot spot = spots[index];
    final List<String> likedBy = <String>[...spot.likedBy];
    final bool has = likedBy.contains(currentUserId);
    if (liked && !has && currentUserId.isNotEmpty) {
      likedBy.add(currentUserId);
    } else if (!liked && has) {
      likedBy.remove(currentUserId);
    }
    final int delta = likedBy.length - spot.likedBy.length;
    spots[index] = spot.copyWith(
      likedBy: likedBy,
      likes: (spot.likes + delta).clamp(0, 1 << 31),
    );
    _emit(planet.id);
  }

  @override
  Future<int> deleteSpotsByAuthor(Planet planet, String authorId) async {
    if (authorId.isEmpty) return 0;
    final List<MapSpot> spots = _spotsFor(planet);
    final int before = spots.length;
    spots.removeWhere((MapSpot spot) => spot.authorId == authorId);
    final int removed = before - spots.length;
    if (removed > 0) _emit(planet.id);
    return removed;
  }

  @override
  void dispose() {
    for (final StreamController<List<MapSpot>> controller
        in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  List<MapSpot> _spotsFor(Planet planet) => _cache.putIfAbsent(
    planet.id,
    () => List<MapSpot>.of(_generate(planet)),
  );

  List<MapSpot> _snapshot(String planetId) =>
      List<MapSpot>.unmodifiable(_cache[planetId] ?? const <MapSpot>[]);

  StreamController<List<MapSpot>> _controller(String planetId) =>
      _controllers.putIfAbsent(
        planetId,
        () => StreamController<List<MapSpot>>.broadcast(),
      );

  void _emit(String planetId) {
    final StreamController<List<MapSpot>>? controller = _controllers[planetId];
    if (controller != null && !controller.isClosed) {
      controller.add(_snapshot(planetId));
    }
  }

  List<MapSpot> _generate(Planet planet) {
    final int seed = _hash(planet.id);
    final List<_SpotTemplate> pool = _poolFor(planet.keywords);
    final int count = 6 + seed % 4; // 6..9 отметок

    return List<MapSpot>.generate(count, (int i) {
      final _SpotTemplate template = pool[(seed + i * 3) % pool.length];
      final double x = 0.12 + 0.76 * _rnd(seed + i * 17 + 1);
      final double y = 0.14 + 0.72 * _rnd(seed + i * 29 + 2);
      final double latitude = 66 - y * 132;
      final double longitude = x * 360 - 180;
      final List<String> tags = <String>{
        ...template.tags,
        ...planet.keywords.take(2),
      }.toList(growable: false);
      final int likes = 4 + (seed + i * 13) % 240;
      final int commentCount = (seed + i * 7) % 4;

      return MapSpot(
        id: '${planet.id}_spot_$i',
        title: template.title,
        description: template.description,
        authorName: _authors[(seed + i * 5) % _authors.length],
        emoji: template.emoji,
        tags: tags,
        likes: likes,
        x: x,
        y: y,
        latitude: latitude,
        longitude: longitude,
        color: i.isEven ? planet.secondary : planet.accent,
        comments: List<MapComment>.generate(commentCount, (int c) {
          final int ci = seed + i * 11 + c * 19;
          return MapComment(
            authorName: _authors[ci % _authors.length],
            text: _comments[ci % _comments.length],
          );
        }, growable: false),
      );
    }, growable: false);
  }

  /// Пул шаблонов отметок под ключевые слова планеты.
  List<_SpotTemplate> _poolFor(List<String> keywords) {
    final List<_SpotTemplate> result = <_SpotTemplate>[];
    for (final String keyword in keywords) {
      result.addAll(_byKeyword[keyword] ?? const <_SpotTemplate>[]);
    }
    if (result.isEmpty) result.addAll(_generic);
    return result;
  }

  static int _hash(String value) {
    int h = 2166136261;
    for (final int code in value.codeUnits) {
      h ^= code;
      h = (h * 16777619) & 0x7fffffff;
    }
    return h;
  }

  static double _rnd(int i) {
    final double x = (i * 9301 + 49297) % 233280 / 233280;
    return x - x.floorToDouble();
  }
}

class _SpotTemplate {
  const _SpotTemplate({
    required this.title,
    required this.description,
    required this.emoji,
    required this.tags,
  });

  final String title;
  final String description;
  final String emoji;
  final List<String> tags;
}

const List<String> _authors = <String>[
  'Аня',
  'Марк',
  'Лена',
  'Дима',
  'Оля',
  'Кирилл',
  'Соня',
  'Тимур',
];

const List<String> _comments = <String>[
  'Были тут — очень понравилось!',
  'Обязательно вернусь сюда.',
  'Место изменило мои выходные.',
  'Кто со мной в следующие выходные?',
  'Лучшее место в городе, серьёзно.',
  'Добавил в свой список мечт.',
];

const List<_SpotTemplate> _generic = <_SpotTemplate>[
  _SpotTemplate(
    title: 'Любимое место',
    description: 'Проверенная точка, куда хочется возвращаться.',
    emoji: '📍',
    tags: <String>['Совет'],
  ),
  _SpotTemplate(
    title: 'Встреча сообщества',
    description: 'Здесь мы собираемся вместе и знакомимся.',
    emoji: '🤝',
    tags: <String>['Сообщество'],
  ),
];

const Map<String, List<_SpotTemplate>> _byKeyword =
    <String, List<_SpotTemplate>>{
      'Природа': <_SpotTemplate>[
        _SpotTemplate(
          title: 'Тихий берег',
          description: 'Безлюдный уголок для отдыха и длинных прогулок.',
          emoji: '🏞️',
          tags: <String>['Природа', 'Отдых'],
        ),
        _SpotTemplate(
          title: 'Смотровая площадка',
          description: 'Отсюда открывается лучший вид на закат.',
          emoji: '🌄',
          tags: <String>['Природа', 'Фото'],
        ),
      ],
      'Спорт': <_SpotTemplate>[
        _SpotTemplate(
          title: 'Спортзал на районе',
          description: 'Дружелюбный зал с разумным абонементом.',
          emoji: '🏋️',
          tags: <String>['Спорт', 'Тренировка'],
        ),
        _SpotTemplate(
          title: 'Беговая дорожка',
          description: 'Классический маршрут на утреннюю пробежку.',
          emoji: '🏃',
          tags: <String>['Спорт', 'Утро'],
        ),
      ],
      'Путешествия': <_SpotTemplate>[
        _SpotTemplate(
          title: 'Автовокзал',
          description: 'Отсюда начинаются все спонтанные поездки.',
          emoji: '🚌',
          tags: <String>['Путешествия', 'Дорога'],
        ),
        _SpotTemplate(
          title: 'Хостел мечты',
          description: 'Уютный хостел с лучшими попутчиками.',
          emoji: '🛏️',
          tags: <String>['Путешествия', 'Ночлег'],
        ),
      ],
      'Фотография': <_SpotTemplate>[
        _SpotTemplate(
          title: 'Точка для кадра',
          description: 'Ракурс, который всегда получается эффектным.',
          emoji: '📷',
          tags: <String>['Фото', 'Ракурс'],
        ),
      ],
      'Кино': <_SpotTemplate>[
        _SpotTemplate(
          title: 'Старый кинотеатр',
          description: 'Здесь показывают классику по вторникам.',
          emoji: '🎦',
          tags: <String>['Кино', 'Классика'],
        ),
      ],
      'Искусство': <_SpotTemplate>[
        _SpotTemplate(
          title: 'Галерея современного искусства',
          description: 'Молодые художники и смелые выставки.',
          emoji: '🖼️',
          tags: <String>['Искусство', 'Выставка'],
        ),
      ],
    };
