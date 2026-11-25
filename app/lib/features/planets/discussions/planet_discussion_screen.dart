import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/discussion_message.dart';
import '../../../data/models/planet.dart';
import '../../../data/models/planet_discussion.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/planet_providers.dart';
import '../../../data/repositories/discussion_photo_repository.dart';
import '../../../data/services/moderation_service.dart';
import 'widgets/discussion_photo.dart';

/// Лента сообщений одного обсуждения: отзывы, оценки и фото участников.
class PlanetDiscussionScreen extends ConsumerStatefulWidget {
  const PlanetDiscussionScreen({
    super.key,
    required this.planetId,
    required this.discussionId,
  });

  final String planetId;
  final String discussionId;

  @override
  ConsumerState<PlanetDiscussionScreen> createState() =>
      _PlanetDiscussionScreenState();
}

class _PlanetDiscussionScreenState
    extends ConsumerState<PlanetDiscussionScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Uint8List> _photos = <Uint8List>[];
  int? _rating;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickPhotos() async {
    final int remaining =
        DiscussionPhotoRepository.maxPhotosPerMessage - _photos.length;
    if (remaining <= 0) {
      _showError('Можно приложить не более трёх фото.');
      return;
    }
    final List<XFile> files = await ImagePicker().pickMultiImage(
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (files.isEmpty) return;

    final List<Uint8List> picked = <Uint8List>[];
    for (final XFile file in files.take(remaining)) {
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.length > DiscussionPhotoRepository.maxPhotoBytes) {
        _showError('Каждое фото должно быть не больше 5 МБ.');
        continue;
      }
      picked.add(bytes);
    }
    if (!mounted || picked.isEmpty) return;
    setState(() => _photos.addAll(picked));
  }

  Future<void> _send(Planet planet, PlanetDiscussion discussion) async {
    final String text = _textController.text.trim();
    if (text.isEmpty && _photos.isEmpty && _rating == null) return;

    if (text.isNotEmpty) {
      final ModerationVerdict verdict = const MockModerationService().checkText(
        text,
      );
      if (verdict.flagged) {
        _showError('Сообщение заблокировано: ${verdict.message}');
        return;
      }
    }

    final String uid = ref.read(currentUserIdProvider);
    final String name =
        ref.read(currentProfileProvider).valueOrNull?.name.trim() ?? '';
    final String messageId = const Uuid().v4();
    final String createdAt = DateTime.now().toIso8601String();
    final List<Uint8List> photos = List<Uint8List>.of(_photos);

    try {
      final List<String> urls = await ref
          .read(discussionPhotoRepositoryProvider)
          .uploadPhotos(
            planetId: planet.id,
            discussionId: discussion.id,
            messageId: messageId,
            uid: uid,
            photos: photos,
          );
      final DiscussionMessage message = DiscussionMessage(
        id: messageId,
        discussionId: discussion.id,
        authorId: uid,
        authorName: name.isEmpty ? 'Вы' : name,
        text: text,
        rating: _rating,
        photoUrls: urls,
        createdAt: createdAt,
      );
      await ref
          .read(planetDiscussionRepositoryProvider)
          .addMessage(planet, discussion.id, message);
    } catch (_) {
      _showError('Не удалось отправить сообщение. Попробуйте ещё раз.');
      return;
    }
    if (!mounted) return;
    setState(() {
      _textController.clear();
      _photos.clear();
      _rating = null;
    });
    _scrollToBottom();
  }

  Future<void> _toggleLike(
    Planet planet,
    DiscussionMessage message,
    bool liked,
  ) async {
    try {
      await ref
          .read(planetDiscussionRepositoryProvider)
          .toggleLike(planet, message.discussionId, message.id, liked);
    } catch (_) {
      _showError('Не удалось изменить лайк.');
    }
  }

  Future<void> _confirmDeleteMessage(
    Planet planet,
    DiscussionMessage message,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Удалить сообщение?'),
        content: const Text('Сообщение исчезнет у всех участников планеты.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(planetDiscussionRepositoryProvider)
          .removeMessage(planet, message.discussionId, message.id);
    } catch (_) {
      _showError('Не удалось удалить сообщение.');
    }
  }

  Future<void> _confirmDeleteDiscussion(
    Planet planet,
    PlanetDiscussion discussion,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Удалить обсуждение?'),
        content: Text(
          '«${discussion.title}» исчезнет у всех участников планеты.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(planetDiscussionRepositoryProvider)
          .removeDiscussion(planet, discussion.id);
    } catch (_) {
      _showError('Не удалось удалить обсуждение.');
      return;
    }
    if (!mounted) return;
    context.go('/main/planet/${planet.id}/discussions');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openPhoto(String url) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(dialogContext),
          child: DiscussionPhoto(url: url, size: 320),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Planet? planet = ref.watch(planetByIdProvider(widget.planetId));
    if (planet == null) {
      return Scaffold(
        appBar: NeonAppBar(
          title: 'Обсуждение',
          leading: BackButton(
            onPressed: () =>
                context.go('/main/planet/${widget.planetId}/discussions'),
          ),
        ),
        body: const Center(child: Text('Планета не найдена')),
      );
    }

    final AsyncValue<List<PlanetDiscussion>> discussionsAsync = ref.watch(
      planetDiscussionsProvider(planet.id),
    );
    final PlanetDiscussion? discussion = _findDiscussion(
      discussionsAsync.valueOrNull,
      widget.discussionId,
    );

    if (discussion == null) {
      return Scaffold(
        appBar: NeonAppBar(
          title: 'Обсуждение',
          leading: BackButton(
            onPressed: () =>
                context.go('/main/planet/${planet.id}/discussions'),
          ),
        ),
        body: Center(
          child: discussionsAsync.isLoading
              ? const CircularProgressIndicator()
              : const Text('Обсуждение не найдено'),
        ),
      );
    }

    final AsyncValue<List<DiscussionMessage>> messagesAsync = ref.watch(
      discussionMessagesProvider(
        DiscussionMessagesKey(planetId: planet.id, discussionId: discussion.id),
      ),
    );
    final List<DiscussionMessage> messages =
        messagesAsync.valueOrNull ?? const <DiscussionMessage>[];
    final String viewerId = ref.watch(currentUserIdProvider);
    final bool canModerate = discussion.isAuthor(viewerId);

    ref.listen<AsyncValue<List<DiscussionMessage>>>(
      discussionMessagesProvider(
        DiscussionMessagesKey(planetId: planet.id, discussionId: discussion.id),
      ),
      (
        AsyncValue<List<DiscussionMessage>>? previous,
        AsyncValue<List<DiscussionMessage>> next,
      ) {
        if (next.hasValue) _scrollToBottom();
      },
    );

    return Scaffold(
      appBar: NeonAppBar(
        title: discussion.title,
        leading: BackButton(
          onPressed: () => context.go('/main/planet/${planet.id}/discussions'),
        ),
        actions: <Widget>[
          if (canModerate)
            IconButton(
              key: const ValueKey<String>('delete-discussion-button'),
              tooltip: 'Удалить обсуждение',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDeleteDiscussion(planet, discussion),
            ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
            children: <Widget>[
              _Header(discussion: discussion, messages: messages),
              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object error, StackTrace stackTrace) => const Center(
                    child: Text('Не удалось загрузить сообщения'),
                  ),
                  data: (List<DiscussionMessage> list) {
                    if (list.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: AppSpacing.page,
                          child: Text(
                            'Пока нет сообщений. Напишите первый отзыв!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      key: const ValueKey<String>('discussion-messages-list'),
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) {
                        final DiscussionMessage message = list[index];
                        final bool isMine = message.isAuthor(viewerId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _MessageRow(
                            message: message,
                            isMine: isMine,
                            canDelete: isMine || canModerate,
                            onLike: () => _toggleLike(
                              planet,
                              message,
                              !message.isLikedBy(viewerId),
                            ),
                            onDelete: () =>
                                _confirmDeleteMessage(planet, message),
                            onPhotoTap: _openPhoto,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              _Composer(
                controller: _textController,
                photos: _photos,
                rating: _rating,
                accent: planet.accent,
                onPickPhotos: _pickPhotos,
                onRemovePhoto: (int index) =>
                    setState(() => _photos.removeAt(index)),
                onRatingChanged: (int? value) =>
                    setState(() => _rating = value),
                onSend: () => _send(planet, discussion),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PlanetDiscussion? _findDiscussion(
  List<PlanetDiscussion>? discussions,
  String id,
) {
  if (discussions == null) return null;
  for (final PlanetDiscussion item in discussions) {
    if (item.id == id) return item;
  }
  return null;
}

class _Header extends StatelessWidget {
  const _Header({required this.discussion, required this.messages});

  final PlanetDiscussion discussion;
  final List<DiscussionMessage> messages;

  @override
  Widget build(BuildContext context) {
    final List<int> ratings = <int>[
      for (final DiscussionMessage message in messages)
        if (message.rating != null) message.rating!,
    ];
    final double? average = ratings.isEmpty
        ? null
        : ratings.reduce((int a, int b) => a + b) / ratings.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(discussion.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    discussion.title,
                    style: AppTextStyles.bodyBold(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (discussion.description.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                discussion.description,
                style: AppTextStyles.body(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                if (discussion.topic.isNotEmpty)
                  Text(
                    discussion.topic,
                    style: AppTextStyles.label(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                const SizedBox(width: AppSpacing.md),
                if (average != null)
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        average.toStringAsFixed(1),
                        style: AppTextStyles.label(),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        '(${ratings.length})',
                        style: AppTextStyles.caption(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.isMine,
    required this.canDelete,
    required this.onLike,
    required this.onDelete,
    required this.onPhotoTap,
  });

  final DiscussionMessage message;
  final bool isMine;
  final bool canDelete;
  final VoidCallback onLike;
  final VoidCallback onDelete;
  final ValueChanged<String> onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return GlassCard(
      borderColor: isMine ? accent.withValues(alpha: 0.8) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  message.authorName.isEmpty ? 'Участник' : message.authorName,
                  style: AppTextStyles.label(color: accent),
                ),
              ),
              if (message.rating != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int i = 1; i <= 5; i++)
                      Icon(
                        i <= message.rating!
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 15,
                        color: i <= message.rating! ? Colors.amber : accent,
                      ),
                  ],
                ),
            ],
          ),
          if (message.text.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(message.text, style: AppTextStyles.body()),
          ],
          if (message.photoUrls.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                for (final String url in message.photoUrls)
                  DiscussionPhoto(
                    key: ValueKey<String>(url),
                    url: url,
                    onTap: () => onPhotoTap(url),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              InkWell(
                onTap: onLike,
                borderRadius: AppRadius.pillAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        message.likedBy.isEmpty
                            ? Icons.thumb_up_outlined
                            : Icons.thumb_up_rounded,
                        size: 16,
                        color: accent,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        '${message.likedBy.length}',
                        style: AppTextStyles.caption(color: accent),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (canDelete)
                IconButton(
                  key: ValueKey<String>('delete-message-${message.id}'),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.textMuted,
                  onPressed: onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.photos,
    required this.rating,
    required this.accent,
    required this.onPickPhotos,
    required this.onRemovePhoto,
    required this.onRatingChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final List<Uint8List> photos;
  final int? rating;
  final Color accent;
  final VoidCallback onPickPhotos;
  final ValueChanged<int> onRemovePhoto;
  final ValueChanged<int?> onRatingChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        border: Border(top: BorderSide(color: accent.withValues(alpha: 0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (photos.isNotEmpty)
            SizedBox(
              height: 76,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                itemBuilder: (BuildContext context, int index) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: AppRadius.mdAll,
                        child: Image.memory(
                          photos[index],
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          key: ValueKey<String>('remove-photo-$index'),
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.white,
                          onPressed: () => onRemovePhoto(index),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Wrap(
            spacing: AppSpacing.xxs,
            runSpacing: AppSpacing.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text('Оценка:', style: AppTextStyles.label()),
              for (int i = 1; i <= 5; i++)
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    key: ValueKey<String>('rating-$i'),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      rating != null && i <= rating!
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 22,
                    ),
                    onPressed: () => onRatingChanged(rating == i ? null : i),
                  ),
                ),
              Text(
                rating == null ? 'необязательно' : '$rating из 5',
                style: AppTextStyles.caption(color: AppColors.textMuted),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: TextField(
                  key: const ValueKey<String>('discussion-message-field'),
                  controller: controller,
                  style: AppTextStyles.body(),
                  cursorColor: accent,
                  decoration: InputDecoration(
                    hintText: 'Написать отзыв...',
                    border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
                    isDense: true,
                    hintStyle: AppTextStyles.body(color: AppColors.textMuted),
                  ),
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: kIsWeb ? TextInputAction.send : null,
                  onSubmitted: (String _) => onSend(),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                key: const ValueKey<String>('discussion-add-photo-button'),
                tooltip: 'Добавить фото (до 3)',
                icon: Icon(Icons.add_photo_alternate_outlined, color: accent),
                onPressed: onPickPhotos,
              ),
              const SizedBox(width: AppSpacing.xs),
              NeonButton(
                key: const ValueKey<String>('discussion-send-button'),
                label: 'Отправить',
                icon: Icons.send_rounded,
                color: accent,
                onPressed: onSend,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
