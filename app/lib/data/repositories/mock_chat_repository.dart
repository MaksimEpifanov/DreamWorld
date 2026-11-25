import 'dart:async';

import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../services/realtime_service.dart';
import 'chat_repository.dart';
import 'mock_profile_repository.dart';

/// Чаты в памяти с сид-диалогами для демо.
class MockChatRepository implements ChatRepository {
  MockChatRepository({
    this.currentUserId = MockProfileRepository.defaultCurrentUserId,
    this.realtime,
  }) {
    _seed();
  }

  /// Идентификатор текущего пользователя.
  final String currentUserId;

  /// Опциональная шина реалтайм-событий.
  final RealtimeService? realtime;
  final Uuid _uuid = const Uuid();
  final Map<String, Conversation> _conversations = <String, Conversation>{};
  final Map<String, List<Message>> _messages = <String, List<Message>>{};
  final StreamController<List<Conversation>> _conversationController =
      StreamController<List<Conversation>>.broadcast();
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();

  void _seed() {
    final DateTime now = DateTime.now();

    final List<Message> anna = <Message>[
      Message(
        id: 'msg_anna_1',
        conversationId: 'c_anna',
        senderId: 'p_anna',
        text: 'Hey! I loved your photos from the mountains 🏔️',
        translatedText:
            'Привет! Мне очень понравились твои горные фотографии 🏔️',
        translatedTo: 'ru',
        status: MessageStatus.read,
        isRead: true,
        createdAt: now.subtract(const Duration(minutes: 42)),
      ),
      Message(
        id: 'msg_anna_2',
        conversationId: 'c_anna',
        senderId: currentUserId,
        text: 'Спасибо! Планирую новую поездку на Камчатку.',
        status: MessageStatus.read,
        isRead: true,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      Message(
        id: 'msg_anna_3',
        conversationId: 'c_anna',
        senderId: 'p_anna',
        text: 'No way, I am originally from Kamchatka!',
        translatedText: 'Невероятно, я родом с Камчатки!',
        translatedTo: 'ru',
        status: MessageStatus.delivered,
        createdAt: now.subtract(const Duration(minutes: 12)),
      ),
    ];
    _messages['c_anna'] = anna;
    _conversations['c_anna'] = Conversation(
      id: 'c_anna',
      participantIds: <String>[currentUserId, 'p_anna'],
      lastMessage: anna.last,
      unreadCount: 1,
      updatedAt: anna.last.createdAt,
    );

    final List<Message> leo = <Message>[
      Message(
        id: 'msg_leo_1',
        conversationId: 'c_leo',
        senderId: 'p_leo',
        text: 'Hi! Want to try a new board game this weekend?',
        status: MessageStatus.read,
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Message(
        id: 'msg_leo_2',
        conversationId: 'c_leo',
        senderId: currentUserId,
        text: 'Звучит отлично, я в деле!',
        status: MessageStatus.sent,
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
    ];
    _messages['c_leo'] = leo;
    _conversations['c_leo'] = Conversation(
      id: 'c_leo',
      participantIds: <String>[currentUserId, 'p_leo'],
      lastMessage: leo.last,
      updatedAt: leo.last.createdAt,
    );
  }

  @override
  Future<List<Conversation>> getConversations() async => _sortedConversations();

  @override
  Stream<List<Conversation>> watchConversations() async* {
    yield _sortedConversations();
    yield* _conversationController.stream;
  }

  @override
  Future<Conversation?> getConversationById(String id) async =>
      _conversations[id];

  @override
  Future<Conversation> getOrCreateConversation(String otherUserId) async {
    final Conversation? existing = _conversations.values.firstWhereOrNull(
      (Conversation conversation) =>
          conversation.participantIds.contains(otherUserId) &&
          conversation.participantIds.contains(currentUserId),
    );
    if (existing != null) return existing;

    final Conversation conversation = Conversation(
      id: _uuid.v4(),
      participantIds: <String>[currentUserId, otherUserId],
      updatedAt: DateTime.now(),
    );
    _conversations[conversation.id] = conversation;
    _notifyConversations();
    realtime?.emit(
      RealtimeEvent.conversationUpdated(conversation: conversation),
    );
    return conversation;
  }

  @override
  Future<List<Message>> getMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    final List<Message> messages = _messages[conversationId] ?? <Message>[];
    return List<Message>.unmodifiable(
      messages.length <= limit
          ? messages
          : messages.sublist(messages.length - limit),
    );
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) async* {
    yield await getMessages(conversationId);
    yield* _messageController.stream
        .where((Message message) => message.conversationId == conversationId)
        .map((Message _) => _messages[conversationId] ?? <Message>[])
        .map(List<Message>.unmodifiable);
  }

  @override
  Future<Message> sendMessage(
    String conversationId,
    String text, {
    String? audioUrl,
    int audioDurationMs = 0,
  }) async {
    final Message message = Message(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: currentUserId,
      text: text,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
      audioUrl: audioUrl,
      audioDurationMs: audioDurationMs,
    );
    final List<Message> messages = _messages.putIfAbsent(
      conversationId,
      () => <Message>[],
    );
    messages.add(message);

    final Conversation? conversation = _conversations[conversationId];
    if (conversation != null) {
      final Conversation updated = conversation.copyWith(
        lastMessage: message,
        updatedAt: message.createdAt,
      );
      _conversations[conversationId] = updated;
      _notifyConversations();
      realtime?.emit(RealtimeEvent.conversationUpdated(conversation: updated));
    }

    if (!_messageController.isClosed) _messageController.add(message);
    realtime?.emit(RealtimeEvent.message(message: message));
    return message;
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    final Conversation? conversation = _conversations[conversationId];
    if (conversation == null) return;

    final List<Message> messages = _messages[conversationId] ?? <Message>[];
    for (int i = 0; i < messages.length; i++) {
      final Message message = messages[i];
      if (!message.isRead && message.senderId != currentUserId) {
        messages[i] = message.copyWith(
          isRead: true,
          status: MessageStatus.read,
        );
      }
    }
    _conversations[conversationId] = conversation.copyWith(
      unreadCount: 0,
      lastMessage: messages.lastOrNull,
    );
    _notifyConversations();
  }

  List<Conversation> _sortedConversations() {
    final List<Conversation> conversations = _conversations.values.toList(
      growable: false,
    );
    conversations.sort(
      (Conversation a, Conversation b) =>
          (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
    );
    return List<Conversation>.unmodifiable(conversations);
  }

  void _notifyConversations() {
    if (_conversationController.isClosed) return;
    _conversationController.add(_sortedConversations());
  }

  @override
  void dispose() {
    _conversationController.close();
    _messageController.close();
  }
}
