// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 String get id; String get name; int get age; String? get bio; String? get photoUrl; List<String> get photoUrls; String? get city; String? get country; List<Interest> get interests; List<String> get goals; List<String> get values; List<String> get languages; RelationshipGoal get relationshipGoal; bool get isOnline; DateTime? get lastSeenAt; DateTime? get createdAt; List<String> get detailedInterests; List<String> get joinedPlanetIds;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.age, _this.age) || other.age == _this.age)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&const DeepCollectionEquality().equals(other.photoUrls, _this.photoUrls)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.country, _this.country) || other.country == _this.country)&&const DeepCollectionEquality().equals(other.interests, _this.interests)&&const DeepCollectionEquality().equals(other.goals, _this.goals)&&const DeepCollectionEquality().equals(other.values, _this.values)&&const DeepCollectionEquality().equals(other.languages, _this.languages)&&(identical(other.relationshipGoal, _this.relationshipGoal) || other.relationshipGoal == _this.relationshipGoal)&&(identical(other.isOnline, _this.isOnline) || other.isOnline == _this.isOnline)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.detailedInterests, _this.detailedInterests)&&const DeepCollectionEquality().equals(other.joinedPlanetIds, _this.joinedPlanetIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hash(runtimeType,_this.id,_this.name,_this.age,_this.bio,_this.photoUrl,const DeepCollectionEquality().hash(_this.photoUrls),_this.city,_this.country,const DeepCollectionEquality().hash(_this.interests),const DeepCollectionEquality().hash(_this.goals),const DeepCollectionEquality().hash(_this.values),const DeepCollectionEquality().hash(_this.languages),_this.relationshipGoal,_this.isOnline,_this.lastSeenAt,_this.createdAt,const DeepCollectionEquality().hash(_this.detailedInterests),const DeepCollectionEquality().hash(_this.joinedPlanetIds));
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(id: ${_this.id}, name: ${_this.name}, age: ${_this.age}, bio: ${_this.bio}, photoUrl: ${_this.photoUrl}, photoUrls: ${_this.photoUrls}, city: ${_this.city}, country: ${_this.country}, interests: ${_this.interests}, goals: ${_this.goals}, values: ${_this.values}, languages: ${_this.languages}, relationshipGoal: ${_this.relationshipGoal}, isOnline: ${_this.isOnline}, lastSeenAt: ${_this.lastSeenAt}, createdAt: ${_this.createdAt}, detailedInterests: ${_this.detailedInterests}, joinedPlanetIds: ${_this.joinedPlanetIds})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, int age, String? bio, String? photoUrl, List<String> photoUrls, String? city, String? country, List<Interest> interests, List<String> goals, List<String> values, List<String> languages, RelationshipGoal relationshipGoal, bool isOnline, DateTime? lastSeenAt, DateTime? createdAt, List<String> detailedInterests, List<String> joinedPlanetIds
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? age = null,Object? bio = freezed,Object? photoUrl = freezed,Object? photoUrls = null,Object? city = freezed,Object? country = freezed,Object? interests = null,Object? goals = null,Object? values = null,Object? languages = null,Object? relationshipGoal = null,Object? isOnline = null,Object? lastSeenAt = freezed,Object? createdAt = freezed,Object? detailedInterests = null,Object? joinedPlanetIds = null,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<Interest>,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as List<String>,values: null == values ? _self.values : values // ignore: cast_nullable_to_non_nullable
as List<String>,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,relationshipGoal: null == relationshipGoal ? _self.relationshipGoal : relationshipGoal // ignore: cast_nullable_to_non_nullable
as RelationshipGoal,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,detailedInterests: null == detailedInterests ? _self.detailedInterests : detailedInterests // ignore: cast_nullable_to_non_nullable
as List<String>,joinedPlanetIds: null == joinedPlanetIds ? _self.joinedPlanetIds : joinedPlanetIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int age,  String? bio,  String? photoUrl,  List<String> photoUrls,  String? city,  String? country,  List<Interest> interests,  List<String> goals,  List<String> values,  List<String> languages,  RelationshipGoal relationshipGoal,  bool isOnline,  DateTime? lastSeenAt,  DateTime? createdAt,  List<String> detailedInterests,  List<String> joinedPlanetIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.name,_that.age,_that.bio,_that.photoUrl,_that.photoUrls,_that.city,_that.country,_that.interests,_that.goals,_that.values,_that.languages,_that.relationshipGoal,_that.isOnline,_that.lastSeenAt,_that.createdAt,_that.detailedInterests,_that.joinedPlanetIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int age,  String? bio,  String? photoUrl,  List<String> photoUrls,  String? city,  String? country,  List<Interest> interests,  List<String> goals,  List<String> values,  List<String> languages,  RelationshipGoal relationshipGoal,  bool isOnline,  DateTime? lastSeenAt,  DateTime? createdAt,  List<String> detailedInterests,  List<String> joinedPlanetIds)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.name,_that.age,_that.bio,_that.photoUrl,_that.photoUrls,_that.city,_that.country,_that.interests,_that.goals,_that.values,_that.languages,_that.relationshipGoal,_that.isOnline,_that.lastSeenAt,_that.createdAt,_that.detailedInterests,_that.joinedPlanetIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int age,  String? bio,  String? photoUrl,  List<String> photoUrls,  String? city,  String? country,  List<Interest> interests,  List<String> goals,  List<String> values,  List<String> languages,  RelationshipGoal relationshipGoal,  bool isOnline,  DateTime? lastSeenAt,  DateTime? createdAt,  List<String> detailedInterests,  List<String> joinedPlanetIds)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.name,_that.age,_that.bio,_that.photoUrl,_that.photoUrls,_that.city,_that.country,_that.interests,_that.goals,_that.values,_that.languages,_that.relationshipGoal,_that.isOnline,_that.lastSeenAt,_that.createdAt,_that.detailedInterests,_that.joinedPlanetIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile extends Profile {
  const _Profile({required this.id, required this.name, required this.age, this.bio, this.photoUrl,  List<String> photoUrls = const <String>[], this.city, this.country,  List<Interest> interests = const <Interest>[],  List<String> goals = const <String>[],  List<String> values = const <String>[],  List<String> languages = const <String>[], this.relationshipGoal = RelationshipGoal.chat, this.isOnline = true, this.lastSeenAt, this.createdAt,  List<String> detailedInterests = const <String>[],  List<String> joinedPlanetIds = const <String>[]}): _photoUrls = photoUrls,_interests = interests,_goals = goals,_values = values,_languages = languages,_detailedInterests = detailedInterests,_joinedPlanetIds = joinedPlanetIds,super._();
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override final  String name;
@override final  int age;
@override final  String? bio;
@override final  String? photoUrl;
 final  List<String> _photoUrls;
@override@JsonKey() List<String> get photoUrls {
  if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoUrls);
}

@override final  String? city;
@override final  String? country;
 final  List<Interest> _interests;
@override@JsonKey() List<Interest> get interests {
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interests);
}

 final  List<String> _goals;
@override@JsonKey() List<String> get goals {
  if (_goals is EqualUnmodifiableListView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goals);
}

 final  List<String> _values;
@override@JsonKey() List<String> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}

 final  List<String> _languages;
@override@JsonKey() List<String> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

@override@JsonKey() final  RelationshipGoal relationshipGoal;
@override@JsonKey() final  bool isOnline;
@override final  DateTime? lastSeenAt;
@override final  DateTime? createdAt;
 final  List<String> _detailedInterests;
@override@JsonKey() List<String> get detailedInterests {
  if (_detailedInterests is EqualUnmodifiableListView) return _detailedInterests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_detailedInterests);
}

 final  List<String> _joinedPlanetIds;
@override@JsonKey() List<String> get joinedPlanetIds {
  if (_joinedPlanetIds is EqualUnmodifiableListView) return _joinedPlanetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_joinedPlanetIds);
}


/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&const DeepCollectionEquality().equals(other.photoUrls, _photoUrls)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&const DeepCollectionEquality().equals(other.interests, _interests)&&const DeepCollectionEquality().equals(other.goals, _goals)&&const DeepCollectionEquality().equals(other.values, _values)&&const DeepCollectionEquality().equals(other.languages, _languages)&&(identical(other.relationshipGoal, relationshipGoal) || other.relationshipGoal == relationshipGoal)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.detailedInterests, _detailedInterests)&&const DeepCollectionEquality().equals(other.joinedPlanetIds, _joinedPlanetIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,age,bio,photoUrl,const DeepCollectionEquality().hash(_photoUrls),city,country,const DeepCollectionEquality().hash(_interests),const DeepCollectionEquality().hash(_goals),const DeepCollectionEquality().hash(_values),const DeepCollectionEquality().hash(_languages),relationshipGoal,isOnline,lastSeenAt,createdAt,const DeepCollectionEquality().hash(_detailedInterests),const DeepCollectionEquality().hash(_joinedPlanetIds));
}

@override
String toString() {
    return 'Profile(id: $id, name: $name, age: $age, bio: $bio, photoUrl: $photoUrl, photoUrls: $photoUrls, city: $city, country: $country, interests: $interests, goals: $goals, values: $values, languages: $languages, relationshipGoal: $relationshipGoal, isOnline: $isOnline, lastSeenAt: $lastSeenAt, createdAt: $createdAt, detailedInterests: $detailedInterests, joinedPlanetIds: $joinedPlanetIds)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int age, String? bio, String? photoUrl, List<String> photoUrls, String? city, String? country, List<Interest> interests, List<String> goals, List<String> values, List<String> languages, RelationshipGoal relationshipGoal, bool isOnline, DateTime? lastSeenAt, DateTime? createdAt, List<String> detailedInterests, List<String> joinedPlanetIds
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? age = null,Object? bio = freezed,Object? photoUrl = freezed,Object? photoUrls = null,Object? city = freezed,Object? country = freezed,Object? interests = null,Object? goals = null,Object? values = null,Object? languages = null,Object? relationshipGoal = null,Object? isOnline = null,Object? lastSeenAt = freezed,Object? createdAt = freezed,Object? detailedInterests = null,Object? joinedPlanetIds = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,interests: null == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<Interest>,goals: null == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as List<String>,values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<String>,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,relationshipGoal: null == relationshipGoal ? _self.relationshipGoal : relationshipGoal // ignore: cast_nullable_to_non_nullable
as RelationshipGoal,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,detailedInterests: null == detailedInterests ? _self._detailedInterests : detailedInterests // ignore: cast_nullable_to_non_nullable
as List<String>,joinedPlanetIds: null == joinedPlanetIds ? _self._joinedPlanetIds : joinedPlanetIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
