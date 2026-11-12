import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/index.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/index.dart';

/// Выбор фото профиля: галерея или камера.
///
/// Фото кодируется в data URI ([encodeImageToDataUri]) и отдаётся наружу
/// через [onPicked]; родитель сохраняет его в `Profile.photoUrl`.
/// Работает на web: `image_picker` возвращает [XFile], а `readAsBytes`
/// доступен на всех платформах.
class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    super.key,
    required this.photoDataUri,
    required this.onPicked,
    this.height = 200,
  });

  /// Текущее фото (data URI) или `null`, если фото ещё нет.
  final String? photoDataUri;

  /// Вызывается с data URI выбранного изображения.
  final ValueChanged<String> onPicked;

  /// Высота области предпросмотра.
  final double height;

  Future<void> _pick(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    final Uint8List bytes = await file.readAsBytes();
    onPicked(encodeImageToDataUri(bytes));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Uint8List? bytes = decodeDataUri(photoDataUri);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () => _pick(ImageSource.gallery),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: GlowContainer(
              color: scheme.primary,
              glowRadius: bytes != null ? 24 : 14,
              glowOpacity: bytes != null ? 0.5 : 0.3,
              borderColor: bytes != null
                  ? scheme.primary.withValues(alpha: 0.6)
                  : scheme.primary.withValues(alpha: 0.4),
              background: AppColors.surface,
              borderRadius: AppRadius.lgAll,
              child: ClipRRect(
                borderRadius: AppRadius.lgAll,
                child: bytes != null
                    ? SizedBox.expand(
                        child: Image.memory(bytes, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 56,
                          color: scheme.primary,
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            Flexible(
              child: TextButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Галерея'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: TextButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Камера'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
