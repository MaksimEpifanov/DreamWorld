import '../models/conversation.dart';
import '../models/message.dart';

/// Чаты: диалоги и сообщения.
abstract interface class ChatRepository {
  /// Список диалогов (по дате последнего сообщения).
  Future<List<Conversation>> getConversations();

  /// Поток диалогов: первый элемент — текущее состояние.
  Stream<List<Conversation>> watchConversations();

  /// Диалог по идентификатору.
  Future<Conversation?> getConversationById(String id);

  /// Диалог с пользователем [otherUserId]: существующий или новый.
  Future<Conversation> getOrCreateConversation(String otherUserId);

  /// Сообщения диалога (последние [limit]).
  Future<List<Message>> getMessages(String conversationId, {int limit = 50});

  /// Поток сообщений диалога.
  Stream<List<Message>> watchMessages(String conversationId);

  /// Отправка сообщения от текущего пользователя.
  Future<Message> sendMessage(
    String conversationId,
    String text, {
    String? audioUrl,
    int audioDurationMs = 0,
  });

  /// Пометить диалог прочитанным.
  Future<void> markAsRead(String conversationId);

  /// Освобождение ресурсов (потоки).
  void dispose();
}
