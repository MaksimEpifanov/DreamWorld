import 'package:dreem_world/data/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const String photoUri = 'data:image/jpeg;base64,AAAA';

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('главное фото доступно провайдеру сразу после загрузки', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(await container.read(mainProfilePhotoProvider.future), isNull);

    final album = await container
        .read(profilePhotosRepositoryProvider)
        .createAlbum('Мои фото');
    await container
        .read(profilePhotosRepositoryProvider)
        .addPhotos(album.id, <String>[photoUri]);
    container.invalidate(mainProfilePhotoProvider);

    expect(await container.read(mainProfilePhotoProvider.future), photoUri);
  });
}
