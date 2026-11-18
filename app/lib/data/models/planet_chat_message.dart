import 'message.dart';

/// Сообщение в общем чате планеты.
///
/// В отличие от личного диалога ([Message]), у сообщения сообщества есть имя
/// отправителя: его видят все участники планеты. Модель простая (без freezed),
/// чтобы не усложнять сериализацию Firestore.
class PlanetChatMessage {
  const PlanetChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  factory PlanetChatMessage.fromJson(Map<String, dynamic> json) =>
      PlanetChatMessage(
        id: '${json['id'] ?? ''}',
        senderId: '${json['senderId'] ?? ''}',
        senderName: '${json['senderName'] ?? ''}',
        text: '${json['text'] ?? ''}',
        createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      );

  /// Представление в виде обычного сообщения — чтобы переиспользовать пузырь
  /// чата ([MessageBubble]) без дублирования оформления.
  Message toMessage() => Message(
    id: id,
    conversationId: 'planet',
    senderId: senderId,
    text: text,
    status: MessageStatus.sent,
    createdAt: createdAt,
  );
}
