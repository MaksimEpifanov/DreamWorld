import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/discussion_message.dart';
import '../models/planet.dart';
import '../models/planet_discussion.dart';
import 'planet_discussion_repository.dart';

/// Обсуждения планет в Firestore.
///
/// Пути: `planets/{planetId}/discussions/{discussionId}` и
/// `planets/{planetId}/discussions/{discussionId}/messages/{messageId}`.
class FirestorePlanetDiscussionRepository
    implements PlanetDiscussionRepository {
  FirestorePlanetDiscussionRepository({
    this.firestore,
    required this.currentUserId,
  });

  static const String planetsCollection = 'planets';
  static const String discussionsCollection = 'discussions';
  static const String messagesCollection = 'messages';

  /// Явный клиент Firestore (для тестов); в приложении создаётся лениво.
  final FirebaseFirestore? firestore;
  final String currentUserId;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  bool get _online => currentUserId.isNotEmpty;

  CollectionReference<Map<String, dynamic>> _discussions(String planetId) => _db
      .collection(planetsCollection)
      .doc(planetId)
      .collection(discussionsCollection);

  CollectionReference<Map<String, dynamic>> _messages(
    String planetId,
    String discussionId,
  ) => _discussions(planetId).doc(discussionId).collection(messagesCollection);

  void _logError(Object error) {
    debugPrint('Обсуждения Firestore недоступны: $error');
  }

  List<PlanetDiscussion> _parseDiscussions(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final List<PlanetDiscussion> result = <PlanetDiscussion>[];
    for (final DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final Map<String, dynamic>? data = doc.data();
      if (data == null) continue;
      try {
        result.add(
          PlanetDiscussion.fromJson(<String, dynamic>{...data, 'id': doc.id}),
        );
      } catch (error) {
        _logError(error);
      }
    }
    return List<PlanetDiscussion>.unmodifiable(result);
  }

  List<DiscussionMessage> _parseMessages(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final List<DiscussionMessage> result = <DiscussionMessage>[];
    for (final DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final Map<String, dynamic>? data = doc.data();
      if (data == null) continue;
      try {
        result.add(
          DiscussionMessage.fromJson(<String, dynamic>{...data, 'id': doc.id}),
        );
      } catch (error) {
        _logError(error);
      }
    }
    return List<DiscussionMessage>.unmodifiable(result);
  }

  @override
  Stream<List<PlanetDiscussion>> watchDiscussions(Planet planet) {
    if (!_online) return Stream<List<PlanetDiscussion>>.value(const []);
    return _discussions(planet.id)
        .orderBy('lastActivityAt', descending: true)
        .snapshots()
        .map(_parseDiscussions)
        .handleError((Object error) {
          _logError(error);
        });
  }

  @override
  Stream<List<DiscussionMessage>> watchMessages(
    String planetId,
    String discussionId,
  ) {
    if (!_online) return Stream<List<DiscussionMessage>>.value(const []);
    return _messages(planetId, discussionId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(_parseMessages)
        .handleError((Object error) {
          _logError(error);
        });
  }

  @override
  Future<void> addDiscussion(Planet planet, PlanetDiscussion discussion) async {
    if (!_online) return;
    try {
      await _discussions(planet.id).doc(discussion.id).set(discussion.toJson());
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  Future<void> addMessage(
    Planet planet,
    String discussionId,
    DiscussionMessage message,
  ) async {
    if (!_online) return;
    try {
      final WriteBatch batch = _db.batch();
      batch.set(
        _messages(planet.id, discussionId).doc(message.id),
        message.toJson(),
      );
      batch.update(_discussions(planet.id).doc(discussionId), <String, dynamic>{
        'messagesCount': FieldValue.increment(1),
        'lastActivityAt': message.createdAt,
      });
      await batch.commit();
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  Future<void> toggleLike(
    Planet planet,
    String discussionId,
    String messageId,
    bool liked,
  ) async {
    if (!_online) return;
    try {
      await _messages(planet.id, discussionId).doc(messageId).update(
        <String, dynamic>{
          'likedBy': liked
              ? FieldValue.arrayUnion(<String>[currentUserId])
              : FieldValue.arrayRemove(<String>[currentUserId]),
        },
      );
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  Future<void> removeDiscussion(Planet planet, String discussionId) async {
    if (!_online) return;
    try {
      final QuerySnapshot<Map<String, dynamic>> messages = await _messages(
        planet.id,
        discussionId,
      ).get();
      final WriteBatch batch = _db.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> message
          in messages.docs) {
        batch.delete(message.reference);
      }
      batch.delete(_discussions(planet.id).doc(discussionId));
      await batch.commit();
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  Future<void> removeMessage(
    Planet planet,
    String discussionId,
    String messageId,
  ) async {
    if (!_online) return;
    try {
      final WriteBatch batch = _db.batch();
      batch.delete(_messages(planet.id, discussionId).doc(messageId));
      batch.update(_discussions(planet.id).doc(discussionId), <String, dynamic>{
        'messagesCount': FieldValue.increment(-1),
      });
      await batch.commit();
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  void dispose() {}
}
