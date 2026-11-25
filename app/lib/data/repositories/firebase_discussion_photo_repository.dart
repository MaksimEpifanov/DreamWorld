import 'dart:typed_data';

import '../../core/utils/image_utils.dart';
import 'discussion_photo_repository.dart';

/// Фото обсуждений без Firebase Storage: сжатые data URI в Firestore.
///
/// Бесплатный вариант: фото сжимаются до 640 px / JPEG 70 и сохраняются как
/// `data:image/jpeg;base64,...` прямо в документе сообщения. Это укладывается
/// в лимит документа Firestore (1 МБ) при трёх фото.
class FirebaseDiscussionPhotoRepository implements DiscussionPhotoRepository {
  const FirebaseDiscussionPhotoRepository({Object? storage});

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
