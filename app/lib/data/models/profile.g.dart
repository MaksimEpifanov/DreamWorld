// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  bio: json['bio'] as String?,
  photoUrl: json['photoUrl'] as String?,
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  city: json['city'] as String?,
  country: json['country'] as String?,
  interests:
      (json['interests'] as List<dynamic>?)
          ?.map((e) => Interest.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Interest>[],
  goals:
      (json['goals'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  values:
      (json['values'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  languages:
      (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  relationshipGoal:
      $enumDecodeNullable(
        _$RelationshipGoalEnumMap,
        json['relationshipGoal'],
      ) ??
      RelationshipGoal.chat,
  isOnline: json['isOnline'] as bool? ?? true,
  lastSeenAt: json['lastSeenAt'] == null
      ? null
      : DateTime.parse(json['lastSeenAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  detailedInterests:
      (json['detailedInterests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  joinedPlanetIds:
      (json['joinedPlanetIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  contactIds:
      (json['contactIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'age': instance.age,
  'bio': instance.bio,
  'photoUrl': instance.photoUrl,
  'photoUrls': instance.photoUrls,
  'city': instance.city,
  'country': instance.country,
  'interests': instance.interests.map((e) => e.toJson()).toList(),
  'goals': instance.goals,
  'values': instance.values,
  'languages': instance.languages,
  'relationshipGoal': _$RelationshipGoalEnumMap[instance.relationshipGoal]!,
  'isOnline': instance.isOnline,
  'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'detailedInterests': instance.detailedInterests,
  'joinedPlanetIds': instance.joinedPlanetIds,
  'contactIds': instance.contactIds,
};

const _$RelationshipGoalEnumMap = {
  RelationshipGoal.chat: 'chat',
  RelationshipGoal.friendship: 'friendship',
  RelationshipGoal.dating: 'dating',
  RelationshipGoal.serious: 'serious',
};
