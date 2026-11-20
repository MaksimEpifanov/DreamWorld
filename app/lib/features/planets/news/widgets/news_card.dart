import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import '../../../../data/models/planet_news.dart';

/// Карточка одной новости ленты планеты.
class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.news,
    required this.planet,
    this.onTap,
    this.compact = false,
  });

  final PlanetNewsItem news;
  final Planet planet;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double imageSize = compact ? 22 : 44;
    final double iconSize = compact ? 10 : 16;
    return GlassCard(
      compact: compact,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  borderRadius: compact ? AppRadius.smAll : AppRadius.mdAll,
                  gradient: LinearGradient(
                    colors: <Color>[planet.primary, planet.secondary],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  news.emoji,
                  style: TextStyle(fontSize: compact ? 11 : 22),
                ),
              ),
              SizedBox(width: compact ? CompactSpace.sm : AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      news.title,
                      style: compact
                          ? CompactText.bodyBold()
                          : AppTextStyles.bodyBold(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: compact ? CompactSpace.xxs : AppSpacing.xxs),
                    Text(
                      '${news.sourceName} · ${relativeTime(news.publishedAt)}',
                      style:
                          compact ? CompactText.caption() : AppTextStyles.caption(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? CompactSpace.xs : AppSpacing.sm),
          Text(
            news.summary,
            style: (compact ? CompactText.body() : AppTextStyles.body())
                .copyWith(color: AppColors.textSecondary),
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: compact ? CompactSpace.xs : AppSpacing.sm),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? CompactSpace.xs : AppSpacing.sm,
                  vertical: compact ? 1 : 2,
                ),
                decoration: BoxDecoration(
                  color: planet.accent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  '#${news.tag}',
                  style: (compact ? CompactText.label() : AppTextStyles.label())
                      .copyWith(color: planet.accent),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.favorite_border_rounded,
                size: iconSize,
                color: AppColors.textMuted,
              ),
              SizedBox(width: compact ? CompactSpace.xxs : AppSpacing.xxs),
              Text(
                '${news.likes}',
                style: compact ? CompactText.caption() : AppTextStyles.caption(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Относительное время вида «5 мин назад», «2 ч назад».
String relativeTime(DateTime time, {DateTime? now}) {
  final DateTime reference = now ?? DateTime.now();
  final Duration diff = reference.difference(time);
  if (diff.inMinutes < 1) return 'только что';
  if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
  if (diff.inHours < 24) return '${diff.inHours} ч назад';
  return '${diff.inDays} дн назад';
}
