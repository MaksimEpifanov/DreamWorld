import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/index.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/index.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/repositories/profile_photos_repository.dart';
import 'photo_picker.dart';

/// Раздел управления локальными альбомами и главным фото профиля.
class PhotoAlbumsSection extends ConsumerWidget {
  const PhotoAlbumsSection({super.key});

  Future<void> _showAlbumDialog(
    BuildContext context,
    WidgetRef ref, {
    PhotoAlbum? album,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: album?.title ?? '',
    );
    final String? title = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(album == null ? 'Новый альбом' : 'Переименовать альбом'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Название'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.trim().isEmpty) return;

    final ProfilePhotosRepository repo =
        ref.read(profilePhotosRepositoryProvider);
    if (album == null) {
      await repo.createAlbum(title);
    } else {
      await repo.renameAlbum(album.id, title);
    }
  }

  Future<void> _deleteAlbum(
    BuildContext context,
    WidgetRef ref,
    PhotoAlbum album,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Удалить альбом?'),
        content: Text('Альбом «${album.title}» и все его фото будут удалены.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(profilePhotosRepositoryProvider).deleteAlbum(album.id);
    ref.invalidate(mainProfilePhotoProvider);
  }

  void _showPicker(BuildContext context, WidgetRef ref, String albumId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      builder: (BuildContext context) => SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: PhotoPicker(
            photoDataUri: null,
            height: 140,
            allowMultiple: true,
            onPicked: (_) {},
            onPickedMultiple: (List<String> uris) async {
              await ref
                  .read(profilePhotosRepositoryProvider)
                  .addPhotos(albumId, uris);
              ref.invalidate(mainProfilePhotoProvider);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showPhotoActions(
    BuildContext context,
    WidgetRef ref,
    PhotoAlbum album,
    AlbumPhoto photo,
    bool isMain,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (!isMain)
              ListTile(
                leading: const Icon(Icons.star_border_rounded),
                title: const Text('Сделать аватаром'),
                onTap: () async {
                  await ref
                      .read(profilePhotosRepositoryProvider)
                      .setMainPhotoId(photo.id);
                  ref.invalidate(mainPhotoIdProvider);
                  ref.invalidate(mainProfilePhotoProvider);
                  if (context.mounted) Navigator.pop(context);
                },
              )
            else
              const ListTile(
                leading: Icon(Icons.star_rounded),
                title: Text('Это главное фото'),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Удалить фото'),
              onTap: () async {
                await ref
                    .read(profilePhotosRepositoryProvider)
                    .deletePhoto(album.id, photo.id);
                ref.invalidate(mainProfilePhotoProvider);
                if (context.mounted) Navigator.pop(context);
              },
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
    final String? mainPhotoId = ref.watch(mainPhotoIdProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text('Фото и альбомы', style: AppTextStyles.title()),
            ),
            TextButton.icon(
              onPressed: () => _showAlbumDialog(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Новый'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        albumsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => Text(
            'Не удалось загрузить фото',
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
          data: (List<PhotoAlbum> albums) {
            if (albums.isEmpty) {
              return NeonCard(
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.photo_library_outlined, size: 40),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Альбомов пока нет. Создайте альбом и загрузите фото — '
                      'первое из них станет аватаром.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: <Widget>[
                ...albums.map(
                  (PhotoAlbum album) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: NeonCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  album.title,
                                  style: AppTextStyles.bodyBold(),
                                ),
                              ),
                              Text(
                                '${album.photos.length}',
                                style: AppTextStyles.caption(),
                              ),
                              IconButton(
                                tooltip: 'Переименовать',
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _showAlbumDialog(
                                  context,
                                  ref,
                                  album: album,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Удалить альбом',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                onPressed: () => _deleteAlbum(context, ref, album),
                              ),
                            ],
                          ),
                          if (album.photos.isNotEmpty)
                            GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: AppSpacing.xs,
                              crossAxisSpacing: AppSpacing.xs,
                              children: <Widget>[
                                ...album.photos.map(
                                  (AlbumPhoto photo) => _PhotoTile(
                                    photo: photo,
                                    isMain: photo.id == mainPhotoId,
                                    onTap: () => _showPhotoActions(
                                      context,
                                      ref,
                                      album,
                                      photo,
                                      photo.id == mainPhotoId,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => _showPicker(
                                context,
                                ref,
                                album.id,
                              ),
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 18,
                              ),
                              label: const Text('Добавить фото'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.isMain,
    required this.onTap,
  });

  final AlbumPhoto photo;
  final bool isMain;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = decodeDataUri(photo.dataUri);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (bytes != null)
              Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true)
            else
              Container(color: AppColors.surface),
            if (isMain)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF35E58A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    size: 12,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
