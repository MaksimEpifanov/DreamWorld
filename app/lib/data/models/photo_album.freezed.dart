// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_album.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlbumPhoto {

 String get id; String get dataUri; DateTime? get createdAt;
/// Create a copy of AlbumPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlbumPhotoCopyWith<AlbumPhoto> get copyWith => _$AlbumPhotoCopyWithImpl<AlbumPhoto>(this as AlbumPhoto, _$identity);

  /// Serializes this AlbumPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AlbumPhoto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlbumPhoto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.dataUri, _this.dataUri) || other.dataUri == _this.dataUri)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AlbumPhoto;
  return Object.hash(runtimeType,_this.id,_this.dataUri,_this.createdAt);
}

@override
String toString() {
  final _this = this as AlbumPhoto;
  return 'AlbumPhoto(id: ${_this.id}, dataUri: ${_this.dataUri}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $AlbumPhotoCopyWith<$Res>  {
  factory $AlbumPhotoCopyWith(AlbumPhoto value, $Res Function(AlbumPhoto) _then) = _$AlbumPhotoCopyWithImpl;
@useResult
$Res call({
 String id, String dataUri, DateTime? createdAt
});




}
/// @nodoc
class _$AlbumPhotoCopyWithImpl<$Res>
    implements $AlbumPhotoCopyWith<$Res> {
  _$AlbumPhotoCopyWithImpl(this._self, this._then);

  final AlbumPhoto _self;
  final $Res Function(AlbumPhoto) _then;

/// Create a copy of AlbumPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dataUri = null,Object? createdAt = freezed,}) {
  return _then(AlbumPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dataUri: null == dataUri ? _self.dataUri : dataUri // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AlbumPhoto].
extension AlbumPhotoPatterns on AlbumPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlbumPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlbumPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlbumPhoto value)  $default,){
final _that = this;
switch (_that) {
case _AlbumPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlbumPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _AlbumPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String dataUri,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlbumPhoto() when $default != null:
return $default(_that.id,_that.dataUri,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String dataUri,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _AlbumPhoto():
return $default(_that.id,_that.dataUri,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String dataUri,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AlbumPhoto() when $default != null:
return $default(_that.id,_that.dataUri,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlbumPhoto implements AlbumPhoto {
  const _AlbumPhoto({required this.id, required this.dataUri, this.createdAt});
  factory _AlbumPhoto.fromJson(Map<String, dynamic> json) => _$AlbumPhotoFromJson(json);

@override final  String id;
@override final  String dataUri;
@override final  DateTime? createdAt;

/// Create a copy of AlbumPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlbumPhotoCopyWith<_AlbumPhoto> get copyWith => __$AlbumPhotoCopyWithImpl<_AlbumPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlbumPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlbumPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.dataUri, dataUri) || other.dataUri == dataUri)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,dataUri,createdAt);
}

@override
String toString() {
    return 'AlbumPhoto(id: $id, dataUri: $dataUri, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AlbumPhotoCopyWith<$Res> implements $AlbumPhotoCopyWith<$Res> {
  factory _$AlbumPhotoCopyWith(_AlbumPhoto value, $Res Function(_AlbumPhoto) _then) = __$AlbumPhotoCopyWithImpl;
@override @useResult
$Res call({
 String id, String dataUri, DateTime? createdAt
});




}
/// @nodoc
class __$AlbumPhotoCopyWithImpl<$Res>
    implements _$AlbumPhotoCopyWith<$Res> {
  __$AlbumPhotoCopyWithImpl(this._self, this._then);

  final _AlbumPhoto _self;
  final $Res Function(_AlbumPhoto) _then;

/// Create a copy of AlbumPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dataUri = null,Object? createdAt = freezed,}) {
  return _then(_AlbumPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dataUri: null == dataUri ? _self.dataUri : dataUri // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PhotoAlbum {

 String get id; String get title; List<AlbumPhoto> get photos; DateTime? get createdAt;
/// Create a copy of PhotoAlbum
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoAlbumCopyWith<PhotoAlbum> get copyWith => _$PhotoAlbumCopyWithImpl<PhotoAlbum>(this as PhotoAlbum, _$identity);

  /// Serializes this PhotoAlbum to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PhotoAlbum;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoAlbum&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&const DeepCollectionEquality().equals(other.photos, _this.photos)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PhotoAlbum;
  return Object.hash(runtimeType,_this.id,_this.title,const DeepCollectionEquality().hash(_this.photos),_this.createdAt);
}

@override
String toString() {
  final _this = this as PhotoAlbum;
  return 'PhotoAlbum(id: ${_this.id}, title: ${_this.title}, photos: ${_this.photos}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $PhotoAlbumCopyWith<$Res>  {
  factory $PhotoAlbumCopyWith(PhotoAlbum value, $Res Function(PhotoAlbum) _then) = _$PhotoAlbumCopyWithImpl;
@useResult
$Res call({
 String id, String title, List<AlbumPhoto> photos, DateTime? createdAt
});




}
/// @nodoc
class _$PhotoAlbumCopyWithImpl<$Res>
    implements $PhotoAlbumCopyWith<$Res> {
  _$PhotoAlbumCopyWithImpl(this._self, this._then);

  final PhotoAlbum _self;
  final $Res Function(PhotoAlbum) _then;

/// Create a copy of PhotoAlbum
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? photos = null,Object? createdAt = freezed,}) {
  return _then(PhotoAlbum(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<AlbumPhoto>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoAlbum].
extension PhotoAlbumPatterns on PhotoAlbum {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoAlbum value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoAlbum() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoAlbum value)  $default,){
final _that = this;
switch (_that) {
case _PhotoAlbum():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoAlbum value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoAlbum() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  List<AlbumPhoto> photos,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoAlbum() when $default != null:
return $default(_that.id,_that.title,_that.photos,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  List<AlbumPhoto> photos,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _PhotoAlbum():
return $default(_that.id,_that.title,_that.photos,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  List<AlbumPhoto> photos,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PhotoAlbum() when $default != null:
return $default(_that.id,_that.title,_that.photos,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoAlbum implements PhotoAlbum {
  const _PhotoAlbum({required this.id, required this.title,  List<AlbumPhoto> photos = const <AlbumPhoto>[], this.createdAt}): _photos = photos;
  factory _PhotoAlbum.fromJson(Map<String, dynamic> json) => _$PhotoAlbumFromJson(json);

@override final  String id;
@override final  String title;
 final  List<AlbumPhoto> _photos;
@override@JsonKey() List<AlbumPhoto> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override final  DateTime? createdAt;

/// Create a copy of PhotoAlbum
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoAlbumCopyWith<_PhotoAlbum> get copyWith => __$PhotoAlbumCopyWithImpl<_PhotoAlbum>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoAlbumToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoAlbum&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.photos, _photos)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(_photos),createdAt);
}

@override
String toString() {
    return 'PhotoAlbum(id: $id, title: $title, photos: $photos, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PhotoAlbumCopyWith<$Res> implements $PhotoAlbumCopyWith<$Res> {
  factory _$PhotoAlbumCopyWith(_PhotoAlbum value, $Res Function(_PhotoAlbum) _then) = __$PhotoAlbumCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, List<AlbumPhoto> photos, DateTime? createdAt
});




}
/// @nodoc
class __$PhotoAlbumCopyWithImpl<$Res>
    implements _$PhotoAlbumCopyWith<$Res> {
  __$PhotoAlbumCopyWithImpl(this._self, this._then);

  final _PhotoAlbum _self;
  final $Res Function(_PhotoAlbum) _then;

/// Create a copy of PhotoAlbum
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? photos = null,Object? createdAt = freezed,}) {
  return _then(_PhotoAlbum(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<AlbumPhoto>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
