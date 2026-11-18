import 'dart:async';

import 'package:uuid/uuid.dart';

import '../models/planet.dart';
import '../models/planet_chat_message.dart';
import 'planet_chat_repository.dart';

/// Общий чат планет в памяти (демо-режим без Firebase).
///
/// У каждой планеты свой чат с несколькими демонстрационными сообщениями,
/// чтобы экран не был пустым. Отправленные сообщения живут до перезапуска.
class MockPlanetChatRepository implements PlanetChatRepository {
  MockPlanetChatRepository({this.currentUserId = ''});

  final String currentUserId;
  final Uuid _uuid = const Uuid();

  final Map<String, List<PlanetChatMessage>> _messages =
      <String, List<PlanetChatMessage>>{};
  final StreamController<String> _updates = StreamController<String>.broadcast();

  List<PlanetChatMessage> _for(Planet planet) =>
      _messages.putIfAbsent(planet.id, () => _seed(planet));

  List<PlanetChatMessage> _seed(Planet planet) {
    final DateTime now = DateTime.now();
    return <PlanetChatMessage>[
      PlanetChatMessage(
        id: '${planet.id}_seed_1',
        senderId: 'p_anna',
        senderName: 'Аня',
        text: 'Всем привет! Чем занимаетесь на этой неделе?',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      PlanetChatMessage(
        id: '${planet.id}_seed_2',
        senderId: 'p_mark',
        senderName: 'Марк',
        text: 'Собираюсь на выходных, присоединяйтесь!',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  @override
  Stream<List<PlanetChatMessage>> watchMessages(Planet planet) async* {
    yield List<PlanetChatMessage>.unmodifiable(_for(planet));
    yield* _updates.stream
        .where((String id) => id == planet.id)
        .map(
          (String _) => List<PlanetChatMessage>.unmodifiable(_for(planet)),
        );
  }

  @override
  Future<void> sendMessage(
    Planet planet,
    String text, {
    String senderName = '',
  }) async {
    _for(planet).add(
      PlanetChatMessage(
        id: _uuid.v4(),
        senderId: currentUserId,
        senderName: senderName,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    if (!_updates.isClosed) _updates.add(planet.id);
  }

  @override
  void dispose() {
    _updates.close();
  }
}
