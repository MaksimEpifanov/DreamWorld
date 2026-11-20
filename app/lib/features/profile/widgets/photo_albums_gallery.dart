import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/index.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/index.dart';
import '../../../data/providers/app_providers.dart';

/// Галерея локальных альбомов на странице просмотра своего профиля.
class PhotoAlbumsGallery extends ConsumerWidget {
  const PhotoAlbumsGallery({super.key});

  void _showFullImage(BuildContext context, Uint8List bytes) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: <Widget>[
            Center(child: Image.memory(bytes, fit: BoxFit.contain)),
            Positioned(
              right: 12,
              top: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PhotoAlbum>> albumsAsync = ref.watch(
      photoAlbumsProvider,
    );
    return albumsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (Object error, StackTrace stackTrace) => const SizedBox.shrink(),
      data: (List<PhotoAlbum> albums) {
        if (albums.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Фотоальбомы', style: AppTextStyles.title()),
            const SizedBox(height: AppSpacing.sm),
            ...albums.map(
              (PhotoAlbum album) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: NeonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(album.title, style: AppTextStyles.bodyBold()),
                      const SizedBox(height: AppSpacing.sm),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.xs,
                        crossAxisSpacing: AppSpacing.xs,
                        children: <Widget>[
                          ...album.photos.map((AlbumPhoto photo) {
                            final Uint8List? bytes =
                                decodeDataUri(photo.dataUri);
                            return GestureDetector(
                              onTap: bytes == null
                                  ? null
                                  : () => _showFullImage(context, bytes),
                              child: ClipRRect(
                                borderRadius: AppRadius.mdAll,
                                child: bytes == null
                                    ? Container(color: AppColors.surface)
                                    : Image.memory(
                                        bytes,
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
