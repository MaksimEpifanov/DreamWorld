import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/planet.dart';
import '../models/planet_chat_message.dart';
import 'planet_chat_repository.dart';

/// Общий чат планет в Firestore.
///
/// Путь: `planets/{planetId}/chat/{messageId}`. Сообщения общие для всех
/// участников планеты: написанное одним сразу видят остальные на сайте и в
/// приложении (подписка `snapshots`). Время хранится строкой ISO-8601 — так
/// сортировка по строке совпадает с сортировкой по дате, а модель читается без
/// конвертеров.
class FirestorePlanetChatRepository implements PlanetChatRepository {
  FirestorePlanetChatRepository({
    this.firestore,
    required this.currentUserId,
  });

  static const String planetsCollection = 'planets';
  static const String chatCollection = 'chat';

  /// Явный клиент Firestore (для тестов); в приложении создаётся лениво.
  final FirebaseFirestore? firestore;
  final String currentUserId;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  bool get _online => currentUserId.isNotEmpty;

  CollectionReference<Map<String, dynamic>> _chat(String planetId) => _db
      .collection(planetsCollection)
      .doc(planetId)
      .collection(chatCollection);

  void _logError(Object error) {
    debugPrint('Чат планеты Firestore недоступен: $error');
  }

  List<PlanetChatMessage> _parse(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final List<PlanetChatMessage> messages = <PlanetChatMessage>[];
    for (final DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final Map<String, dynamic>? data = doc.data();
      if (data == null) continue;
      try {
        messages.add(
          PlanetChatMessage.fromJson(<String, dynamic>{...data, 'id': doc.id}),
        );
      } catch (error) {
        _logError(error);
      }
    }
    return List<PlanetChatMessage>.unmodifiable(messages);
  }

  @override
  Stream<List<PlanetChatMessage>> watchMessages(Planet planet) {
    if (!_online) {
      return Stream<List<PlanetChatMessage>>.value(
        const <PlanetChatMessage>[],
      );
    }
    return _chat(planet.id)
        .orderBy('createdAt')
        .snapshots()
        .map(_parse)
        .handleError((Object error) {
          _logError(error);
        });
  }

  @override
  Future<void> sendMessage(
    Planet planet,
    String text, {
    String senderName = '',
  }) async {
    if (!_online) return;
    final DocumentReference<Map<String, dynamic>> reference = _chat(
      planet.id,
    ).doc();
    try {
      await reference.set(<String, dynamic>{
        'id': reference.id,
        'senderId': currentUserId,
        'senderName': senderName,
        'text': text,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  void dispose() {}
}
