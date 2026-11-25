// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Message {

 String get id; String get conversationId; String get senderId; String get text; String? get originalText; String? get translatedText; String get translatedTo; bool get isRead; MessageStatus get status; DateTime? get createdAt; String? get audioUrl; int get audioDurationMs;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Message;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.conversationId, _this.conversationId) || other.conversationId == _this.conversationId)&&(identical(other.senderId, _this.senderId) || other.senderId == _this.senderId)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.originalText, _this.originalText) || other.originalText == _this.originalText)&&(identical(other.translatedText, _this.translatedText) || other.translatedText == _this.translatedText)&&(identical(other.translatedTo, _this.translatedTo) || other.translatedTo == _this.translatedTo)&&(identical(other.isRead, _this.isRead) || other.isRead == _this.isRead)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.audioUrl, _this.audioUrl) || other.audioUrl == _this.audioUrl)&&(identical(other.audioDurationMs, _this.audioDurationMs) || other.audioDurationMs == _this.audioDurationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Message;
  return Object.hash(runtimeType,_this.id,_this.conversationId,_this.senderId,_this.text,_this.originalText,_this.translatedText,_this.translatedTo,_this.isRead,_this.status,_this.createdAt,_this.audioUrl,_this.audioDurationMs);
}

@override
String toString() {
  final _this = this as Message;
  return 'Message(id: ${_this.id}, conversationId: ${_this.conversationId}, senderId: ${_this.senderId}, text: ${_this.text}, originalText: ${_this.originalText}, translatedText: ${_this.translatedText}, translatedTo: ${_this.translatedTo}, isRead: ${_this.isRead}, status: ${_this.status}, createdAt: ${_this.createdAt}, audioUrl: ${_this.audioUrl}, audioDurationMs: ${_this.audioDurationMs})';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 String id, String conversationId, String senderId, String text, String? originalText, String? translatedText, String translatedTo, bool isRead, MessageStatus status, DateTime? createdAt, String? audioUrl, int audioDurationMs
});




}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? text = null,Object? originalText = freezed,Object? translatedText = freezed,Object? translatedTo = null,Object? isRead = null,Object? status = null,Object? createdAt = freezed,Object? audioUrl = freezed,Object? audioDurationMs = null,}) {
  return _then(Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,originalText: freezed == originalText ? _self.originalText : originalText // ignore: cast_nullable_to_non_nullable
as String?,translatedText: freezed == translatedText ? _self.translatedText : translatedText // ignore: cast_nullable_to_non_nullable
as String?,translatedTo: null == translatedTo ? _self.translatedTo : translatedTo // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,audioDurationMs: null == audioDurationMs ? _self.audioDurationMs : audioDurationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String conversationId,  String senderId,  String text,  String? originalText,  String? translatedText,  String translatedTo,  bool isRead,  MessageStatus status,  DateTime? createdAt,  String? audioUrl,  int audioDurationMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.text,_that.originalText,_that.translatedText,_that.translatedTo,_that.isRead,_that.status,_that.createdAt,_that.audioUrl,_that.audioDurationMs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String conversationId,  String senderId,  String text,  String? originalText,  String? translatedText,  String translatedTo,  bool isRead,  MessageStatus status,  DateTime? createdAt,  String? audioUrl,  int audioDurationMs)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.conversationId,_that.senderId,_that.text,_that.originalText,_that.translatedText,_that.translatedTo,_that.isRead,_that.status,_that.createdAt,_that.audioUrl,_that.audioDurationMs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String conversationId,  String senderId,  String text,  String? originalText,  String? translatedText,  String translatedTo,  bool isRead,  MessageStatus status,  DateTime? createdAt,  String? audioUrl,  int audioDurationMs)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.text,_that.originalText,_that.translatedText,_that.translatedTo,_that.isRead,_that.status,_that.createdAt,_that.audioUrl,_that.audioDurationMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Message extends Message {
  const _Message({required this.id, required this.conversationId, required this.senderId, required this.text, this.originalText, this.translatedText, this.translatedTo = '', this.isRead = false, this.status = MessageStatus.sent, this.createdAt, this.audioUrl, this.audioDurationMs = 0}): super._();
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

@override final  String id;
@override final  String conversationId;
@override final  String senderId;
@override final  String text;
@override final  String? originalText;
@override final  String? translatedText;
@override@JsonKey() final  String translatedTo;
@override@JsonKey() final  bool isRead;
@override@JsonKey() final  MessageStatus status;
@override final  DateTime? createdAt;
@override final  String? audioUrl;
@override@JsonKey() final  int audioDurationMs;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.text, text) || other.text == text)&&(identical(other.originalText, originalText) || other.originalText == originalText)&&(identical(other.translatedText, translatedText) || other.translatedText == translatedText)&&(identical(other.translatedTo, translatedTo) || other.translatedTo == translatedTo)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.audioDurationMs, audioDurationMs) || other.audioDurationMs == audioDurationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,conversationId,senderId,text,originalText,translatedText,translatedTo,isRead,status,createdAt,audioUrl,audioDurationMs);
}

@override
String toString() {
    return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, text: $text, originalText: $originalText, translatedText: $translatedText, translatedTo: $translatedTo, isRead: $isRead, status: $status, createdAt: $createdAt, audioUrl: $audioUrl, audioDurationMs: $audioDurationMs)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String conversationId, String senderId, String text, String? originalText, String? translatedText, String translatedTo, bool isRead, MessageStatus status, DateTime? createdAt, String? audioUrl, int audioDurationMs
});




}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? text = null,Object? originalText = freezed,Object? translatedText = freezed,Object? translatedTo = null,Object? isRead = null,Object? status = null,Object? createdAt = freezed,Object? audioUrl = freezed,Object? audioDurationMs = null,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,originalText: freezed == originalText ? _self.originalText : originalText // ignore: cast_nullable_to_non_nullable
as String?,translatedText: freezed == translatedText ? _self.translatedText : translatedText // ignore: cast_nullable_to_non_nullable
as String?,translatedTo: null == translatedTo ? _self.translatedTo : translatedTo // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MessageStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,audioUrl: freezed == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String?,audioDurationMs: null == audioDurationMs ? _self.audioDurationMs : audioDurationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
