import 'dart:typed_data';

/// Загрузка фото сообщений обсуждений.
///
/// В рабочей версии фото уходят в Firebase Storage, а в Firestore пишутся
/// только полученные https-ссылки. В мок-режиме фото остаются data URI в памяти.
abstract class DiscussionPhotoRepository {
  /// Не более трёх фото в одном сообщении.
  static const int maxPhotosPerMessage = 3;

  /// Не более 5 МБ на исходное фото перед сжатием.
  static const int maxPhotoBytes = 5 * 1024 * 1024;

  /// Загружает фото и возвращает ссылки на них в том же порядке.
  Future<List<String>> uploadPhotos({
    required String planetId,
    required String discussionId,
    required String messageId,
    required String uid,
    required List<Uint8List> photos,
  });
}
