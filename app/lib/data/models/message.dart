import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// Статус доставки сообщения.
@JsonEnum()
enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

/// Сообщение в чате.
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required String text,
    String? originalText,
    String? translatedText,
    @Default('') String translatedTo,
    @Default(false) bool isRead,
    @Default(MessageStatus.sent) MessageStatus status,
    DateTime? createdAt,
    String? audioUrl,
    @Default(0) int audioDurationMs,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  const Message._();

  /// Есть ли готовый автоперевод.
  bool get isTranslated => translatedText != null && translatedText!.isNotEmpty;

  /// Есть ли голосовое сообщение.
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  /// Текст для отображения: перевод, если есть, иначе оригинал.
  String get displayText {
    if (hasAudio && text.trim().isEmpty) return 'Голосовое сообщение';
    return isTranslated ? translatedText! : text;
  }
}
