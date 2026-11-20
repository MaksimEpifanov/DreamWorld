import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/planet_scene_theme.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import '../../../../data/models/planet_news.dart';
import '../../../../data/providers/planet_providers.dart';
import '../../news/widgets/news_card.dart';

class CinemaFeaturedNews extends ConsumerWidget {
  const CinemaFeaturedNews({
    super.key,
    required this.planet,
    required this.theme,
  });

  final Planet planet;
  final PlanetSceneTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PlanetNewsItem> news =
        ref.watch(planetNewsProvider(planet.id)).valueOrNull ??
        const <PlanetNewsItem>[];
    if (news.isEmpty) return const SizedBox.shrink();
    final PlanetNewsItem item = news.first;
    final bool isFishing = planet.id == 'p_fishing';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.emoji_events_outlined,
                size: isFishing ? 18 : 12, color: planet.accent),
            const SizedBox(width: CompactSpace.xs),
            Text(
              theme.featuredTitle,
              style: isFishing ? AppTextStyles.title() : CompactText.title(),
            ),
          ],
        ),
        const SizedBox(height: CompactSpace.sm),
        GlassCard(
          key: const ValueKey<String>('cinema-featured-news'),
          compact: true,
          onTap: () => context.go('/main/planet/${planet.id}/news'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.smAll,
                      gradient: LinearGradient(
                        colors: <Color>[planet.primary, planet.secondary],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🏆', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: CompactSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.title,
                          style: CompactText.bodyBold(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: CompactSpace.xxs),
                        Text(
                          '${item.sourceName} · ${relativeTime(item.publishedAt)}',
                          style: CompactText.caption(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CompactSpace.sm),
              Text(
                item.summary,
                style: CompactText.body(color: AppColors.textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: CompactSpace.sm),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.favorite_outline_rounded,
                    size: 10,
                    color: planet.accent,
                  ),
                  const SizedBox(width: CompactSpace.xxs),
                  Text(
                    '${item.likes}',
                    style: CompactText.label(color: planet.accent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
