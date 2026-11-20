import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/photo_album.dart';

/// Локальная фототека профиля: альбомы и фотографии без серверного хранилища.
abstract interface class ProfilePhotosRepository {
  Future<List<PhotoAlbum>> loadAlbums();

  Stream<List<PhotoAlbum>> watchAlbums();

  Future<PhotoAlbum> createAlbum(String title);

  Future<void> renameAlbum(String albumId, String title);

  Future<void> deleteAlbum(String albumId);

  Future<List<AlbumPhoto>> addPhotos(
    String albumId,
    List<String> dataUris,
  );

  Future<void> deletePhoto(String albumId, String photoId);

  Future<AlbumPhoto?> findPhoto(String photoId);

  Future<String?> getMainPhotoId();

  Future<void> setMainPhotoId(String? photoId);

  void dispose();
}

/// Хранит альбомы отдельной маленькой записью, а каждое фото — своей записью.
///
/// Так добавление фото не перезаписывает весь набор(base64) целиком и не
/// упирается в лимит одного значения хранилища.
class LocalProfilePhotosRepository implements ProfilePhotosRepository {
  LocalProfilePhotosRepository({required this.userId});

  final String userId;
  final Uuid _uuid = const Uuid();
  final StreamController<List<PhotoAlbum>> _controller =
      StreamController<List<PhotoAlbum>>.broadcast();

  List<PhotoAlbum> _albums = <PhotoAlbum>[];
  String? _mainPhotoId;
  Future<void>? _restoreFuture;

  String get _albumsKey => 'profile_albums_$userId';
  String get _mainPhotoKey => 'profile_main_photo_$userId';
  String _photoKey(String photoId) => 'profile_photo_${userId}_$photoId';

  Future<void> _ensureRestored() =>
      _restoreFuture ??= _restore();

  DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  Map<String, dynamic> _albumJson(PhotoAlbum album) => <String, dynamic>{
    'id': album.id,
    'title': album.title,
    'createdAt': album.createdAt?.toIso8601String(),
    'photos': album.photos
        .map(
          (AlbumPhoto photo) => <String, dynamic>{
            'id': photo.id,
            'createdAt': photo.createdAt?.toIso8601String(),
          },
        )
        .toList(),
  };

  Future<void> _restore() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_albumsKey);
      if (raw == null || raw.isEmpty) return;

      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final List<PhotoAlbum> albums = <PhotoAlbum>[];
      for (final Object? item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        final Map<String, dynamic> json = Map<String, dynamic>.from(item);
        final String? albumId = json['id'] as String?;
        if (albumId == null) continue;

        final List<AlbumPhoto> photos = <AlbumPhoto>[];
        final Object? photosRaw = json['photos'];
        if (photosRaw is List) {
          for (final Object? photoItem in photosRaw) {
            if (photoItem is! Map<String, dynamic>) continue;
            final Map<String, dynamic> photoJson =
                Map<String, dynamic>.from(photoItem);
            final String? photoId = photoJson['id'] as String?;
            if (photoId == null) continue;
            final String? dataUri = prefs.getString(_photoKey(photoId));
            if (dataUri == null || dataUri.isEmpty) continue;
            photos.add(
              AlbumPhoto(
                id: photoId,
                dataUri: dataUri,
                createdAt: _date(photoJson['createdAt']),
              ),
            );
          }
        }

        albums.add(
          PhotoAlbum(
            id: albumId,
            title: (json['title'] as String?) ?? 'Альбом',
            photos: photos,
            createdAt: _date(json['createdAt']),
          ),
        );
      }
      _albums = albums;
      final String? main = prefs.getString(_mainPhotoKey);
      _mainPhotoId = (main == null || main.isEmpty) ? null : main;
    } catch (_) {
      _albums = <PhotoAlbum>[];
      _mainPhotoId = null;
    }
  }

  Future<void> _persistMainPhotoId() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_mainPhotoId == null) {
        await prefs.remove(_mainPhotoKey);
      } else {
        await prefs.setString(_mainPhotoKey, _mainPhotoId!);
      }
    } catch (_) {
      // Главное фото не должно ломать работу остальной фототеки.
    }
  }

  Future<void> _normalizeMainPhotoId() async {
    if (_mainPhotoId != null &&
        _albums.any(
          (PhotoAlbum album) => album.photos.any(
            (AlbumPhoto photo) => photo.id == _mainPhotoId,
          ),
        )) {
      return;
    }
    _mainPhotoId = null;
    for (final PhotoAlbum album in _albums) {
      if (album.photos.isNotEmpty) {
        _mainPhotoId = album.photos.first.id;
        break;
      }
    }
    await _persistMainPhotoId();
  }

  Future<void> _persistAlbums() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _albumsKey,
        jsonEncode(_albums.map(_albumJson).toList()),
      );
    } catch (_) {
      // Локальная фототека не должна ломать сохранение анкеты.
    }
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List<PhotoAlbum>.unmodifiable(_albums));
    }
  }

  int _indexOf(String albumId) =>
      _albums.indexWhere((PhotoAlbum album) => album.id == albumId);

  @override
  Future<List<PhotoAlbum>> loadAlbums() async {
    await _ensureRestored();
    return List<PhotoAlbum>.unmodifiable(_albums);
  }

  @override
  Stream<List<PhotoAlbum>> watchAlbums() async* {
    await _ensureRestored();
    yield List<PhotoAlbum>.unmodifiable(_albums);
    yield* _controller.stream;
  }

  @override
  Future<PhotoAlbum> createAlbum(String title) async {
    await _ensureRestored();
    final PhotoAlbum album = PhotoAlbum(
      id: _uuid.v4(),
      title: title.trim().isEmpty ? 'Альбом' : title.trim(),
      createdAt: DateTime.now(),
    );
    _albums = <PhotoAlbum>[..._albums, album];
    await _persistAlbums();
    _emit();
    return album;
  }

  @override
  Future<void> renameAlbum(String albumId, String title) async {
    await _ensureRestored();
    final int index = _indexOf(albumId);
    if (index < 0 || title.trim().isEmpty) return;
    _albums[index] = _albums[index].copyWith(title: title.trim());
    await _persistAlbums();
    _emit();
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    await _ensureRestored();
    final int index = _indexOf(albumId);
    if (index < 0) return;
    final PhotoAlbum album = _albums[index];
    _albums = <PhotoAlbum>[..._albums]..removeAt(index);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      for (final AlbumPhoto photo in album.photos) {
        await prefs.remove(_photoKey(photo.id));
      }
    } catch (_) {
      // Ошибка удаления не блокирует обновление списка альбомов.
    }
    await _persistAlbums();
    await _normalizeMainPhotoId();
    _emit();
  }

  @override
  Future<List<AlbumPhoto>> addPhotos(
    String albumId,
    List<String> dataUris,
  ) async {
    await _ensureRestored();
    final int index = _indexOf(albumId);
    if (index < 0 || dataUris.isEmpty) return const <AlbumPhoto>[];

    final DateTime now = DateTime.now();
    final List<AlbumPhoto> added = <AlbumPhoto>[];
    for (final String dataUri in dataUris) {
      if (dataUri.isEmpty) continue;
      added.add(
        AlbumPhoto(
          id: _uuid.v4(),
          dataUri: dataUri,
          createdAt: now,
        ),
      );
    }
    if (added.isEmpty) return const <AlbumPhoto>[];

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      for (final AlbumPhoto photo in added) {
        await prefs.setString(_photoKey(photo.id), photo.dataUri);
      }
      if (_mainPhotoId == null) {
        _mainPhotoId = added.first.id;
        await prefs.setString(_mainPhotoKey, _mainPhotoId!);
      }
    } catch (_) {
      return const <AlbumPhoto>[];
    }

    final PhotoAlbum album = _albums[index];
    _albums[index] = album.copyWith(
      photos: <AlbumPhoto>[...album.photos, ...added],
    );
    await _persistAlbums();
    _emit();
    return List<AlbumPhoto>.unmodifiable(added);
  }

  @override
  Future<void> deletePhoto(String albumId, String photoId) async {
    await _ensureRestored();
    final int index = _indexOf(albumId);
    if (index < 0) return;
    final PhotoAlbum album = _albums[index];
    if (!album.photos.any((AlbumPhoto photo) => photo.id == photoId)) return;

    _albums[index] = album.copyWith(
      photos: album.photos
          .where((AlbumPhoto photo) => photo.id != photoId)
          .toList(),
    );
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_photoKey(photoId));
    } catch (_) {
      // Ошибка удаления не блокирует обновление списка альбомов.
    }
    await _persistAlbums();
    await _normalizeMainPhotoId();
    _emit();
  }

  @override
  Future<AlbumPhoto?> findPhoto(String photoId) async {
    await _ensureRestored();
    for (final PhotoAlbum album in _albums) {
      for (final AlbumPhoto photo in album.photos) {
        if (photo.id == photoId) return photo;
      }
    }
    return null;
  }

  @override
  Future<String?> getMainPhotoId() async {
    await _ensureRestored();
    return _mainPhotoId;
  }

  @override
  Future<void> setMainPhotoId(String? photoId) async {
    await _ensureRestored();
    if (photoId != null &&
        !_albums.any(
          (PhotoAlbum album) => album.photos.any(
            (AlbumPhoto photo) => photo.id == photoId,
          ),
        )) {
      return;
    }
    _mainPhotoId = photoId;
    await _persistMainPhotoId();
    _emit();
  }

  @override
  void dispose() {
    _controller.close();
  }
}
