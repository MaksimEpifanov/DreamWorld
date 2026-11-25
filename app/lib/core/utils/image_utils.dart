import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Кодирует байты изображения в data URI (`data:image/jpeg;base64,...`).
///
/// Используется, чтобы хранить выбранное фото прямо в [String]
/// (`Profile.photoUrl`) — приемлемо для мок-репозитория.
String encodeImageToDataUri(Uint8List bytes, {String mime = 'image/jpeg'}) {
  return 'data:$mime;base64,${base64Encode(bytes)}';
}

/// Возвращает байты локального data URI или `null` для сетевой ссылки.
Uint8List? dataUriBytes(String? url) {
  if (url == null || !url.startsWith('data:')) return null;
  final int comma = url.indexOf(',');
  if (comma < 0) return null;
  try {
    return base64Decode(url.substring(comma + 1));
  } catch (_) {
    return null;
  }
}

/// Возвращает только сетевой URL; локальные data URI не сохраняются в облако.
String? remoteImageUrlOrNull(String? url) =>
    url != null && (url.startsWith('http://') || url.startsWith('https://'))
    ? url
    : null;

/// Сжимает изображение до [maxSize] по большей стороне и качества [quality].
///
/// Возвращает байты JPEG; `null`, если данные не являются изображением.
Future<Uint8List?> compressImageBytes(
  Uint8List bytes, {
  int maxSize = 640,
  int quality = 70,
}) async {
  final img.Image? decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  final int longest = decoded.width > decoded.height
      ? decoded.width
      : decoded.height;
  final double scale = longest > maxSize ? maxSize / longest : 1;
  final int width = (decoded.width * scale).round().clamp(1, maxSize).toInt();
  final int height = (decoded.height * scale).round().clamp(1, maxSize).toInt();
  final img.Image resized = width == decoded.width && height == decoded.height
      ? decoded
      : img.copyResize(
          decoded,
          width: width,
          height: height,
          interpolation: img.Interpolation.average,
        );
  return img.encodeJpg(resized, quality: quality);
}

/// Декодирует data URI обратно в байты; `null`/пустая/битая строка → `null`.
Uint8List? decodeDataUri(String? dataUri) {
  if (dataUri == null || dataUri.isEmpty) return null;
  if (!dataUri.startsWith('data:')) return null;

  final int comma = dataUri.indexOf(',');
  if (comma == -1) return null;

  final String metadata = dataUri.substring('data:'.length, comma);
  if (!metadata.contains(';base64')) return null;

  try {
    return base64Decode(dataUri.substring(comma + 1));
  } on FormatException {
    return null;
  }
}
