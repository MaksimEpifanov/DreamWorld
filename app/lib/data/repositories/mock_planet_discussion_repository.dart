import 'dart:async';

import '../models/discussion_message.dart';
import '../models/planet.dart';
import '../models/planet_discussion.dart';
import 'planet_discussion_repository.dart';

/// Мок-репозиторий обсуждений: память без сети (демо-режим без Firebase).
///
/// Для каждой планеты создаются два демонстрационных обсуждения с сообщениями,
/// чтобы вкладка была непустой без бэкенда. Изменения живут в памяти.
class MockPlanetDiscussionRepository implements PlanetDiscussionRepository {
  MockPlanetDiscussionRepository({this.currentUserId = ''});

  final String currentUserId;

  final Map<String, List<PlanetDiscussion>> _discussions =
      <String, List<PlanetDiscussion>>{};
  final Map<String, List<DiscussionMessage>> _messages =
      <String, List<DiscussionMessage>>{};
  final Map<String, StreamController<List<PlanetDiscussion>>>
  _discussionControllers = <String, StreamController<List<PlanetDiscussion>>>{};
  final Map<String, StreamController<List<DiscussionMessage>>>
  _messageControllers = <String, StreamController<List<DiscussionMessage>>>{};

  @override
  Stream<List<PlanetDiscussion>> watchDiscussions(Planet planet) async* {
    _discussionsFor(planet);
    yield List<PlanetDiscussion>.unmodifiable(_discussions[planet.id]!);
    yield* _discussionController(planet.id).stream;
  }

  @override
  Stream<List<DiscussionMessage>> watchMessages(
    String planetId,
    String discussionId,
  ) async* {
    final String key = _key(planetId, discussionId);
    yield List<DiscussionMessage>.unmodifiable(_messages[key] ?? const []);
    yield* _messageController(key).stream;
  }

  @override
  Future<void> addDiscussion(Planet planet, PlanetDiscussion discussion) async {
    _discussionsFor(planet).insert(0, discussion);
    _emitDiscussions(planet.id);
  }

  @override
  Future<void> addMessage(
    Planet planet,
    String discussionId,
    DiscussionMessage message,
  ) async {
    final String key = _key(planet.id, discussionId);
    _messages.putIfAbsent(key, () => <DiscussionMessage>[]).add(message);
    _emitMessages(key);

    final List<PlanetDiscussion> list = _discussionsFor(planet);
    final int index = list.indexWhere(
      (PlanetDiscussion item) => item.id == discussionId,
    );
    if (index < 0) return;
    list[index] = PlanetDiscussion(
      id: list[index].id,
      planetId: list[index].planetId,
      title: list[index].title,
      description: list[index].description,
      topic: list[index].topic,
      tags: list[index].tags,
      authorId: list[index].authorId,
      authorName: list[index].authorName,
      createdAt: list[index].createdAt,
      messagesCount: list[index].messagesCount + 1,
      lastActivityAt: message.createdAt,
    );
    _emitDiscussions(planet.id);
  }

  @override
  Future<void> toggleLike(
    Planet planet,
    String discussionId,
    String messageId,
    bool liked,
  ) async {
    final String key = _key(planet.id, discussionId);
    final int index = (_messages[key] ?? const <DiscussionMessage>[])
        .indexWhere((DiscussionMessage item) => item.id == messageId);
    if (index < 0) return;
    final DiscussionMessage message = _messages[key]![index];
    final List<String> likedBy = message.likedBy
        .where((String id) => id != currentUserId)
        .toList(growable: true);
    if (liked) likedBy.add(currentUserId);
    _messages[key]![index] = message.copyWith(likedBy: likedBy);
    _emitMessages(key);
  }

  @override
  Future<void> removeDiscussion(Planet planet, String discussionId) async {
    _discussionsFor(planet)
        .removeWhere((PlanetDiscussion item) => item.id == discussionId);
    _messages.remove(_key(planet.id, discussionId));
    _emitDiscussions(planet.id);
  }

  @override
  Future<void> removeMessage(
    Planet planet,
    String discussionId,
    String messageId,
  ) async {
    final String key = _key(planet.id, discussionId);
    _messages[key]?.removeWhere(
      (DiscussionMessage item) => item.id == messageId,
    );
    _emitMessages(key);

    final List<PlanetDiscussion> list = _discussionsFor(planet);
    final int index = list.indexWhere(
      (PlanetDiscussion item) => item.id == discussionId,
    );
    if (index < 0) return;
    list[index] = PlanetDiscussion(
      id: list[index].id,
      planetId: list[index].planetId,
      title: list[index].title,
      description: list[index].description,
      topic: list[index].topic,
      tags: list[index].tags,
      authorId: list[index].authorId,
      authorName: list[index].authorName,
      createdAt: list[index].createdAt,
      messagesCount: list[index].messagesCount > 0
          ? list[index].messagesCount - 1
          : 0,
      lastActivityAt: list[index].lastActivityAt,
    );
    _emitDiscussions(planet.id);
  }

  @override
  void dispose() {
    for (final StreamController<List<PlanetDiscussion>> controller
        in _discussionControllers.values) {
      controller.close();
    }
    for (final StreamController<List<DiscussionMessage>> controller
        in _messageControllers.values) {
      controller.close();
    }
    _discussionControllers.clear();
    _messageControllers.clear();
  }

  String _key(String planetId, String discussionId) =>
      '$planetId|$discussionId';

  List<PlanetDiscussion> _discussionsFor(
    Planet planet,
  ) => _discussions.putIfAbsent(planet.id, () {
    final String keyword = planet.keywords.isEmpty
        ? planet.shortName
        : planet.keywords.first;
    final String secondKeyword = planet.keywords.length > 1
        ? planet.keywords[1]
        : keyword;
    final DateTime now = DateTime.now();
    final String baseId = '${planet.id}_discussion_demo';
    _messages[_key(planet.id, '${baseId}_1')] = <DiscussionMessage>[
      DiscussionMessage(
        id: '${baseId}_1_message_1',
        discussionId: '${baseId}_1',
        authorId: '',
        authorName: 'Аня',
        text: 'Очень понравилось! Поделюсь впечатлениями.',
        rating: 5,
        createdAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
      ),
      DiscussionMessage(
        id: '${baseId}_1_message_2',
        discussionId: '${baseId}_1',
        authorId: '',
        authorName: 'Марк',
        text: 'Подтверждаю, стоит посмотреть. Возьмите с собой фотоаппарат.',
        createdAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
      ),
    ];
    _messages[_key(planet.id, '${baseId}_2')] = <DiscussionMessage>[
      DiscussionMessage(
        id: '${baseId}_2_message_1',
        discussionId: '${baseId}_2',
        authorId: '',
        authorName: 'Лиза',
        text: 'Посмотрела недавно — сильные впечатления, рекомендую.',
        rating: 4,
        createdAt: now.subtract(const Duration(days: 2)).toIso8601String(),
      ),
    ];
    return <PlanetDiscussion>[
      PlanetDiscussion(
        id: '${baseId}_1',
        planetId: planet.id,
        title: '$keyword: делимся находками',
        description: 'Делимся впечатлениями и фотографиями.',
        topic: keyword,
        authorId: '',
        authorName: 'Аня',
        createdAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
        messagesCount: 2,
        lastActivityAt: now
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
      ),
      PlanetDiscussion(
        id: '${baseId}_2',
        planetId: planet.id,
        title: 'Что обсудить: $secondKeyword',
        description: 'Подборка того, что понравилось участникам.',
        topic: secondKeyword,
        authorId: '',
        authorName: 'Лиза',
        createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
        messagesCount: 1,
        lastActivityAt: now.subtract(const Duration(days: 2)).toIso8601String(),
      ),
    ];
  });

  StreamController<List<PlanetDiscussion>> _discussionController(
    String planetId,
  ) => _discussionControllers.putIfAbsent(
    planetId,
    () => StreamController<List<PlanetDiscussion>>.broadcast(),
  );

  StreamController<List<DiscussionMessage>> _messageController(String key) =>
      _messageControllers.putIfAbsent(
        key,
        () => StreamController<List<DiscussionMessage>>.broadcast(),
      );

  void _emitDiscussions(String planetId) {
    final StreamController<List<PlanetDiscussion>>? controller =
        _discussionControllers[planetId];
    if (controller != null && !controller.isClosed) {
      controller.add(
        List<PlanetDiscussion>.unmodifiable(_discussions[planetId] ?? const []),
      );
    }
  }

  void _emitMessages(String key) {
    final StreamController<List<DiscussionMessage>>? controller =
        _messageControllers[key];
    if (controller != null && !controller.isClosed) {
      controller.add(
        List<DiscussionMessage>.unmodifiable(_messages[key] ?? const []),
      );
    }
  }
}
