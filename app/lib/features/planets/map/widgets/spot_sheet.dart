import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/map_spot.dart';
import '../../../../data/models/planet.dart';

/// Открывает нижнюю панель с деталями отметки на карте.
Future<void> showSpotSheet(
  BuildContext context, {
  required MapSpot spot,
  required Planet planet,
  required bool liked,
  required String authorName,
  required String authorId,
  required ValueChanged<MapComment> onCommentAdded,
  required ValueChanged<bool> onLikeToggled,
  VoidCallback? onReport,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => _SpotSheet(
      spot: spot,
      planet: planet,
      liked: liked,
      authorName: authorName,
      authorId: authorId,
      onCommentAdded: onCommentAdded,
      onLikeToggled: onLikeToggled,
      onReport: onReport,
    ),
  );
}

class _SpotSheet extends StatefulWidget {
  const _SpotSheet({
    required this.spot,
    required this.planet,
    required this.liked,
    required this.authorName,
    required this.authorId,
    required this.onCommentAdded,
    required this.onLikeToggled,
    this.onReport,
  });

  final MapSpot spot;
  final Planet planet;
  final bool liked;
  final String authorName;
  final String authorId;
  final ValueChanged<MapComment> onCommentAdded;
  final ValueChanged<bool> onLikeToggled;

  /// Жалоба на автора отметки (если это отметка другого человека).
  final VoidCallback? onReport;

  @override
  State<_SpotSheet> createState() => _SpotSheetState();
}

class _SpotSheetState extends State<_SpotSheet> {
  late int _likes = widget.spot.likes;
  late bool _liked = widget.liked;
  late final List<MapComment> _comments = List<MapComment>.of(
    widget.spot.comments,
  );
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
    widget.onLikeToggled(_liked);
  }

  void _addComment() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      final MapComment comment = MapComment(
        authorName: widget.authorName,
        text: text,
        authorId: widget.authorId,
      );
      _comments.add(comment);
      widget.onCommentAdded(comment);
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.spot.color ?? widget.planet.accent;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          border: Border(top: BorderSide(color: accent.withValues(alpha: 0.4))),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: AppSpacing.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: AppRadius.pillAll,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.lgAll,
                        gradient: LinearGradient(
                          colors: <Color>[
                            widget.planet.primary,
                            widget.planet.secondary,
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.spot.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.spot.title, style: AppTextStyles.title()),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Отметил(а) ${widget.spot.authorName}',
                            style: AppTextStyles.caption(),
                          ),
                        ],
                      ),
                    ),
                    if (widget.onReport != null)
                      IconButton(
                        tooltip: 'Пожаловаться',
                        onPressed: widget.onReport,
                        icon: Icon(
                          Icons.flag_outlined,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.spot.description,
                  style: AppTextStyles.body(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    for (final String tag in widget.spot.tags)
                      _Tag(label: tag, color: accent),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    NeonButton(
                      label: '$_likes',
                      icon: _liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      variant: _liked
                          ? NeonButtonVariant.filled
                          : NeonButtonVariant.outlined,
                      color: accent,
                      onPressed: _toggleLike,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${_comments.length} комментариев',
                      style: AppTextStyles.caption(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Комментарии', style: AppTextStyles.bodyBold()),
                const SizedBox(height: AppSpacing.sm),
                if (_comments.isEmpty)
                  Text(
                    'Пока нет комментариев — будьте первым.',
                    style: AppTextStyles.caption(),
                  )
                else
                  for (final MapComment comment in _comments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _CommentTile(comment: comment, color: accent),
                    ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: AppTextStyles.body(),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _addComment(),
                        decoration: InputDecoration(
                          hintText: 'Оставить комментарий…',
                          hintStyle: AppTextStyles.caption(),
                          filled: true,
                          fillColor: AppColors.background.withValues(
                            alpha: 0.4,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.pillAll,
                            borderSide: BorderSide(
                              color: accent.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.pillAll,
                            borderSide: BorderSide(
                              color: accent.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    NeonButton(
                      label: 'OK',
                      icon: Icons.send_rounded,
                      color: accent,
                      onPressed: _addComment,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text('#$label', style: AppTextStyles.label(color: color)),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.color});

  final MapComment comment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(
            comment.authorName.isEmpty
                ? '?'
                : comment.authorName.substring(0, 1),
            style: AppTextStyles.label(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(comment.authorName, style: AppTextStyles.bodyBold()),
              const SizedBox(height: 2),
              Text(
                comment.text,
                style: AppTextStyles.body(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
