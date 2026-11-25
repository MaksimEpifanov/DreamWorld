import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/utils/image_utils.dart';

/// Фото в сообщении обсуждения: сетевая ссылка из Storage или локальный data URI.
class DiscussionPhoto extends StatelessWidget {
  const DiscussionPhoto({
    super.key,
    required this.url,
    this.size = 88,
    this.onTap,
  });

  final String url;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Uint8List? data = dataUriBytes(url);
    final Widget image = data != null
        ? Image.memory(
            data,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
          )
        : Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
          );

    final Widget content = ClipRRect(
      borderRadius: AppRadius.mdAll,
      child: Container(
        width: size,
        height: size,
        color: AppColors.surfaceElevated,
        child: image,
      ),
    );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}
