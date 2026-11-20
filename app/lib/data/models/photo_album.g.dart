// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlbumPhoto _$AlbumPhotoFromJson(Map<String, dynamic> json) => _AlbumPhoto(
  id: json['id'] as String,
  dataUri: json['dataUri'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AlbumPhotoToJson(_AlbumPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dataUri': instance.dataUri,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_PhotoAlbum _$PhotoAlbumFromJson(Map<String, dynamic> json) => _PhotoAlbum(
  id: json['id'] as String,
  title: json['title'] as String,
  photos:
      (json['photos'] as List<dynamic>?)
          ?.map((e) => AlbumPhoto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AlbumPhoto>[],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PhotoAlbumToJson(_PhotoAlbum instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'photos': instance.photos.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };
