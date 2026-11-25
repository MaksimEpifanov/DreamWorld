import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import '../../../../data/models/planet_discussion.dart';
import '../../../../data/providers/planet_providers.dart';

/// Секция «Обсуждения» на экране планеты: последние темы и переход к списку.
class DiscussionsSection extends ConsumerWidget {
  const DiscussionsSection({
    super.key,
    required this.planet,
    this.compact = false,
  });

  final Planet planet;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PlanetDiscussion>> async = ref.watch(
      planetDiscussionsProvider(planet.id),
    );
    final List<PlanetDiscussion> discussions =
        async.valueOrNull ?? const <PlanetDiscussion>[];
    final String base = '/main/planet/${planet.id}/discussions';

    final double spaceXs = compact ? CompactSpace.xs : AppSpacing.xs;
    final double spaceXxs = compact ? CompactSpace.xxs : AppSpacing.xxs;
    final double spaceSm = compact ? CompactSpace.sm : AppSpacing.sm;
    final double spaceMd = compact ? CompactSpace.sm : AppSpacing.md;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.forum_outlined,
              size: compact ? 12 : 18,
              color: planet.accent,
            ),
            SizedBox(width: spaceXs),
            Expanded(
              child: Text(
                'Обсуждения',
                style: compact ? CompactText.title() : AppTextStyles.title(),
              ),
            ),
            TextButton(
              onPressed: () => context.go(base),
              style: compact
                  ? TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CompactSpace.xs,
                        vertical: CompactSpace.xxs,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )
                  : null,
              child: Text(
                'Все темы',
                style: (compact ? CompactText.label() : AppTextStyles.label())
                    .copyWith(color: planet.accent),
              ),
            ),
          ],
        ),
        SizedBox(height: spaceXxs),
        Text(
          'Места, события, книги и фильмы — с отзывами и фото',
          style: compact ? CompactText.caption() : AppTextStyles.caption(),
        ),
        SizedBox(height: spaceSm),
        if (async.isLoading && discussions.isEmpty)
          Padding(
            padding: EdgeInsets.all(spaceMd),
            child: Center(
              child: SizedBox(
                width: compact ? 16 : 24,
                height: compact ? 16 : 24,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (discussions.isEmpty)
          NeonCard(
            color: planet.accent,
            padding: compact ? const EdgeInsets.all(6) : AppSpacing.card,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.chat_bubble_outline,
                  size: compact ? 14 : 24,
                  color: planet.accent,
                ),
                SizedBox(width: spaceSm),
                Expanded(
                  child: Text(
                    'Пока нет обсуждений — создайте первое.',
                    style: (compact ? CompactText.body() : AppTextStyles.body())
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          )
        else
          for (final PlanetDiscussion discussion in discussions.take(2))
            Padding(
              padding: EdgeInsets.only(bottom: spaceSm),
              child: NeonCard(
                color: planet.accent,
                padding: compact ? const EdgeInsets.all(6) : AppSpacing.card,
                onTap: () => context.go('$base/${discussion.id}'),
                child: Row(
                  children: <Widget>[
                    Text(
                      discussion.emoji,
                      style: TextStyle(fontSize: compact ? 14 : 24),
                    ),
                    SizedBox(width: spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            discussion.title,
                            style: compact
                                ? CompactText.bodyBold()
                                : AppTextStyles.bodyBold(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${discussion.topic.isNotEmpty ? '${discussion.topic} · ' : ''}'
                            '${discussion.messagesCount} сообщений',
                            style: compact
                                ? CompactText.caption()
                                : AppTextStyles.caption(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        SizedBox(height: spaceSm),
        NeonButton(
          label: 'Создать обсуждение',
          icon: Icons.add_comment_outlined,
          variant: NeonButtonVariant.outlined,
          compact: compact,
          expanded: true,
          color: planet.accent,
          onPressed: () => context.go(base),
        ),
      ],
    );
  }
}
