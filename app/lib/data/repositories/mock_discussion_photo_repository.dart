import 'dart:typed_data';

import '../../core/utils/image_utils.dart';
import 'discussion_photo_repository.dart';

/// Мок-загрузка фото: сжимает изображение и отдаёт data URI без сети.
class MockDiscussionPhotoRepository implements DiscussionPhotoRepository {
  const MockDiscussionPhotoRepository();

  @override
  Future<List<String>> uploadPhotos({
    required String planetId,
    required String discussionId,
    required String messageId,
    required String uid,
    required List<Uint8List> photos,
  }) async {
    if (photos.length > DiscussionPhotoRepository.maxPhotosPerMessage) {
      throw ArgumentError('Можно приложить не более трёх фото.');
    }
    final List<String> result = <String>[];
    for (final Uint8List bytes in photos) {
      if (bytes.isEmpty ||
          bytes.length > DiscussionPhotoRepository.maxPhotoBytes) {
        throw ArgumentError('Размер каждого фото должен быть до 5 МБ.');
      }
      final Uint8List? compressed = await compressImageBytes(bytes);
      if (compressed != null) result.add(encodeImageToDataUri(compressed));
    }
    return List<String>.unmodifiable(result);
  }
}
