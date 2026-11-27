import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import 'chat_repository.dart';

/// Чаты в Firestore: диалоги и сообщения видны обоим участникам на сайте
/// и в приложении.
///
/// Идентификатор диалога — детерминированный (`uid1_uid2`, по возрастанию),
/// поэтому обе стороны открывают один и тот же документ без дополнительного
/// поиска. Время хранится строкой ISO-8601: так модели `freezed` читаются
/// без конвертеров, а сортировка по строке совпадает с сортировкой по дате.
class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository({this.firestore, required this.currentUserId});

  static const String conversationsCollection = 'conversations';

  /// Явный клиент Firestore (для тестов); в приложении создаётся лениво.
  final FirebaseFirestore? firestore;
  final String currentUserId;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection(conversationsCollection);

  bool get _online => currentUserId.isNotEmpty;

  String _conversationId(String otherUserId) {
    final List<String> ids = <String>[currentUserId, otherUserId]..sort();
    return '${ids.first}_${ids.last}';
  }

  void _logError(Object error) {
    debugPrint('Чат Firestore недоступен: $error');
  }

  Conversation _conversationFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
    final Map<String, dynamic> unread =
        (data['unreadCounts'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    Message? lastMessage;
    final Object? rawLast = data['lastMessage'];
    if (rawLast is Map<String, dynamic>) {
      try {
        lastMessage = Message.fromJson(rawLast);
      } catch (error) {
        _logError(error);
      }
    }
    return Conversation(
      id: snapshot.id,
      participantIds: (data['participantIds'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic value) => '$value')
          .toList(growable: false),
      lastMessage: lastMessage,
      unreadCount: (unread[currentUserId] as num?)?.toInt() ?? 0,
      updatedAt: _parseDate(data['updatedAt']) ?? _parseDate(data['createdAt']),
    );
  }

  Message _messageFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
    return Message.fromJson(<String, dynamic>{...data, 'id': snapshot.id});
  }

  DateTime? _parseDate(Object? value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    if (value is Timestamp) return value.toDate();
    return null;
  }

  @override
  Future<List<Conversation>> getConversations() async {
    final List<Conversation> result = await _queryConversations();
    return result;
  }

  Future<List<Conversation>> _queryConversations() async {
    if (!_online) return const <Conversation>[];
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _conversations
          .where('participantIds', arrayContains: currentUserId)
          .get();
      return _sorted(snapshot.docs.map(_conversationFromSnapshot));
    } catch (error) {
      _logError(error);
      return const <Conversation>[];
    }
  }

  List<Conversation> _sorted(Iterable<Conversation> conversations) {
    final List<Conversation> result = conversations.toList(growable: false);
    result.sort(
      (Conversation a, Conversation b) =>
          (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
    );
    return List<Conversation>.unmodifiable(result);
  }

  @override
  Stream<List<Conversation>> watchConversations() async* {
    if (!_online) {
      yield const <Conversation>[];
      return;
    }
    yield await getConversations();
    yield* _conversations
        .where('participantIds', arrayContains: currentUserId)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) =>
              _sorted(snapshot.docs.map(_conversationFromSnapshot)),
        )
        .handleError(_logError);
  }

  @override
  Future<Conversation?> getConversationById(String id) async {
    if (!_online) return null;
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _conversations.doc(id).get();
      if (!snapshot.exists) return null;
      return _conversationFromSnapshot(snapshot);
    } catch (error) {
      _logError(error);
      return null;
    }
  }

  @override
  Future<Conversation> getOrCreateConversation(String otherUserId) async {
    final String id = _conversationId(otherUserId);
    final DocumentReference<Map<String, dynamic>> reference = _conversations
        .doc(id);
    final Conversation fallback = Conversation(
      id: id,
      participantIds: <String>[currentUserId, otherUserId],
      updatedAt: DateTime.now(),
    );
    if (!_online) return fallback;

    try {
      DocumentSnapshot<Map<String, dynamic>>? snapshot;
      try {
        snapshot = await reference.get();
      } catch (error) {
        // Правила Firestore запрещают чтение несуществующего диалога, поэтому
        // отказ на чтении означает «диалога ещё нет» — создаём его ниже.
        _logError(error);
      }
      if (snapshot != null && snapshot.exists) {
        return _conversationFromSnapshot(snapshot);
      }

      final String now = DateTime.now().toIso8601String();
      await reference.set(<String, dynamic>{
        'participantIds': <String>[currentUserId, otherUserId],
        'unreadCounts': <String, dynamic>{currentUserId: 0, otherUserId: 0},
        'createdAt': now,
        'updatedAt': now,
      });
      return Conversation(
        id: id,
        participantIds: <String>[currentUserId, otherUserId],
        updatedAt: DateTime.now(),
      );
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  Future<List<Message>> _queryMessages(String conversationId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _conversations
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt')
          .get();
      return snapshot.docs.map(_messageFromSnapshot).toList(growable: false);
    } catch (error) {
      _logError(error);
      return const <Message>[];
    }
  }

  @override
  Future<List<Message>> getMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    final List<Message> messages = await _queryMessages(conversationId);
    if (messages.length <= limit) return messages;
    return messages.sublist(messages.length - limit);
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) async* {
    yield await _queryMessages(conversationId);
    yield* _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) =>
              snapshot.docs.map(_messageFromSnapshot).toList(growable: false),
        )
        .handleError(_logError);
  }

  @override
  Future<Message> sendMessage(
    String conversationId,
    String text, {
    String? audioUrl,
    int audioDurationMs = 0,
  }) async {
    final DateTime now = DateTime.now();
    final DocumentReference<Map<String, dynamic>> messageReference =
        _conversations.doc(conversationId).collection('messages').doc();
    final Message message = Message(
      id: messageReference.id,
      conversationId: conversationId,
      senderId: currentUserId,
      text: text,
      status: MessageStatus.sent,
      createdAt: now,
      audioUrl: audioUrl,
      audioDurationMs: audioDurationMs,
    );

    try {
      final DocumentSnapshot<Map<String, dynamic>> conversation =
          await _conversations.doc(conversationId).get();
      final List<String> participants =
          (conversation.data()?['participantIds'] as List<dynamic>? ??
                  <dynamic>[])
              .map((dynamic value) => '$value')
              .toList(growable: false);
      final String otherId = participants.firstWhere(
        (String id) => id != currentUserId,
        orElse: () => '',
      );

      final Map<String, dynamic> messageData = <String, dynamic>{
        'id': message.id,
        'conversationId': conversationId,
        'senderId': currentUserId,
        'text': text,
        'status': 'sent',
        'isRead': false,
        'createdAt': now.toIso8601String(),
        'audioDurationMs': audioDurationMs,
      };
      if (audioUrl != null && audioUrl.isNotEmpty) {
        messageData['audioUrl'] = audioUrl;
      }
      await messageReference.set(messageData);

      final Map<String, dynamic> update = <String, dynamic>{
        'lastMessage': messageData,
        'updatedAt': now.toIso8601String(),
        'unreadCounts.$currentUserId': 0,
      };
      if (otherId.isNotEmpty) {
        update['unreadCounts.$otherId'] = FieldValue.increment(1);
      }
      await _conversations.doc(conversationId).update(update);
    } catch (error) {
      _logError(error);
      rethrow;
    }
    return message;
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    if (!_online) return;
    try {
      await _conversations.doc(conversationId).update(<String, dynamic>{
        'unreadCounts.$currentUserId': 0,
      });
    } catch (error) {
      _logError(error);
    }
  }

  @override
  Future<void> updateMessageTranscription(
    String conversationId,
    String messageId,
    String transcription,
  ) async {
    if (!_online) return;
    try {
      await _conversations
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update(<String, dynamic>{'transcription': transcription});
    } catch (error) {
      _logError(error);
      rethrow;
    }
  }

  @override
  void dispose() {}
}
