import 'package:dreem_world/data/models/photo_album.dart';
import 'package:dreem_world/data/repositories/profile_photos_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const String firstUri = 'data:image/jpeg;base64,AAAA';
  const String secondUri = 'data:image/jpeg;base64,BBBB';

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('альбомы и фото восстанавливаются между запусками', () async {
    final LocalProfilePhotosRepository repository =
        LocalProfilePhotosRepository(userId: 'u1');
    final PhotoAlbum album = await repository.createAlbum('Отпуск');
    final List<AlbumPhoto> added = await repository.addPhotos(
      album.id,
      <String>[firstUri, secondUri],
    );

    expect(added, hasLength(2));
    expect(await repository.getMainPhotoId(), added.first.id);
    repository.dispose();

    final LocalProfilePhotosRepository restored =
        LocalProfilePhotosRepository(userId: 'u1');
    addTearDown(restored.dispose);

    final List<PhotoAlbum> albums = await restored.loadAlbums();
    expect(albums, hasLength(1));
    expect(albums.single.title, 'Отпуск');
    expect(albums.single.photos.map((AlbumPhoto p) => p.dataUri), <String>[
      firstUri,
      secondUri,
    ]);
    expect(await restored.getMainPhotoId(), added.first.id);
  });

  test('смена главного фото и удаление переключают аватар', () async {
    final LocalProfilePhotosRepository repository =
        LocalProfilePhotosRepository(userId: 'u1');
    addTearDown(repository.dispose);

    final PhotoAlbum album = await repository.createAlbum('Мои фото');
    final List<AlbumPhoto> added = await repository.addPhotos(
      album.id,
      <String>[firstUri, secondUri],
    );

    await repository.setMainPhotoId(added.last.id);
    expect(await repository.getMainPhotoId(), added.last.id);

    await repository.deletePhoto(album.id, added.last.id);
    expect(await repository.getMainPhotoId(), added.first.id);

    await repository.deleteAlbum(album.id);
    expect(await repository.getMainPhotoId(), isNull);
    expect(await repository.loadAlbums(), isEmpty);
  });

  test('главное фото не сохраняется чужим альбомом', () async {
    final LocalProfilePhotosRepository repository =
        LocalProfilePhotosRepository(userId: 'u1');
    addTearDown(repository.dispose);

    final PhotoAlbum album = await repository.createAlbum('Альбом');
    final List<AlbumPhoto> added = await repository.addPhotos(
      album.id,
      <String>[firstUri],
    );

    await repository.setMainPhotoId('чужое-фото');
    expect(await repository.getMainPhotoId(), added.first.id);
  });
}
