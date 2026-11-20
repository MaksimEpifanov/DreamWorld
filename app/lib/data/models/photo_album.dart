import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_album.freezed.dart';
part 'photo_album.g.dart';

/// Фотография в локальной фототеке профиля.
@freezed
abstract class AlbumPhoto with _$AlbumPhoto {
  const factory AlbumPhoto({
    required String id,
    required String dataUri,
    DateTime? createdAt,
  }) = _AlbumPhoto;

  factory AlbumPhoto.fromJson(Map<String, dynamic> json) =>
      _$AlbumPhotoFromJson(json);
}

/// Альбом с фотографиями профиля.
@freezed
abstract class PhotoAlbum with _$PhotoAlbum {
  const factory PhotoAlbum({
    required String id,
    required String title,
    @Default(<AlbumPhoto>[]) List<AlbumPhoto> photos,
    DateTime? createdAt,
  }) = _PhotoAlbum;

  factory PhotoAlbum.fromJson(Map<String, dynamic> json) =>
      _$PhotoAlbumFromJson(json);
}
