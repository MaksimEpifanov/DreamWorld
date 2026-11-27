// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  conversationId: json['conversationId'] as String,
  senderId: json['senderId'] as String,
  text: json['text'] as String,
  originalText: json['originalText'] as String?,
  translatedText: json['translatedText'] as String?,
  translatedTo: json['translatedTo'] as String? ?? '',
  isRead: json['isRead'] as bool? ?? false,
  status:
      $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
      MessageStatus.sent,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  audioUrl: json['audioUrl'] as String?,
  audioDurationMs: (json['audioDurationMs'] as num?)?.toInt() ?? 0,
  transcription: json['transcription'] as String?,
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'senderId': instance.senderId,
  'text': instance.text,
  'originalText': instance.originalText,
  'translatedText': instance.translatedText,
  'translatedTo': instance.translatedTo,
  'isRead': instance.isRead,
  'status': _$MessageStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt?.toIso8601String(),
  'audioUrl': instance.audioUrl,
  'audioDurationMs': instance.audioDurationMs,
  'transcription': instance.transcription,
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
  MessageStatus.failed: 'failed',
};
