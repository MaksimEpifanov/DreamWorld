import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/index.dart';
import '../../../../data/models/planet.dart';
import '../../../../data/models/planet_news.dart';
import '../../../../data/providers/planet_providers.dart';
import 'news_card.dart';

/// Секция «Новости планеты» для экрана планеты: первые новости ленты
/// и переход к полному списку.
class NewsSection extends ConsumerWidget {
  const NewsSection({super.key, required this.planet, this.compact = false});

  final Planet planet;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PlanetNewsItem>> newsAsync = ref.watch(
      planetNewsProvider(planet.id),
    );

    final double spaceXs = compact ? CompactSpace.xs : AppSpacing.xs;
    final double spaceXxs = compact ? CompactSpace.xxs : AppSpacing.xxs;
    final double spaceSm = compact ? CompactSpace.sm : AppSpacing.sm;
    final double spaceLg = compact ? CompactSpace.md : AppSpacing.lg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.auto_awesome,
                size: compact ? 12 : 18, color: planet.accent),
            SizedBox(width: spaceXs),
            Expanded(
              child: Text(
                'Новости планеты',
                style: compact ? CompactText.title() : AppTextStyles.title(),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/main/planet/${planet.id}/news'),
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
                'Показывать все',
                style: (compact ? CompactText.label() : AppTextStyles.label())
                    .copyWith(color: planet.accent),
              ),
            ),
          ],
        ),
        SizedBox(height: spaceXxs),
        Text(
          'Лента обновляется раз в день ИИ-редакцией',
          style: compact ? CompactText.caption() : AppTextStyles.caption(),
        ),
        SizedBox(height: spaceSm),
        newsAsync.when(
          loading: () => Padding(
            padding: EdgeInsets.all(spaceLg),
            child: Center(
              child: SizedBox(
                width: compact ? 16 : 24,
                height: compact ? 16 : 24,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (Object error, StackTrace stackTrace) => Text(
            'Не удалось загрузить новости',
            style: (compact ? CompactText.body() : AppTextStyles.body())
                .copyWith(color: AppColors.textMuted),
          ),
          data: (List<PlanetNewsItem> news) {
            if (news.isEmpty) {
              return Text(
                'Пока нет новостей',
                style: compact ? CompactText.caption() : AppTextStyles.caption(),
              );
            }
            return Column(
              children: <Widget>[
                for (final PlanetNewsItem item in news.take(3))
                  Padding(
                    padding: EdgeInsets.only(bottom: spaceSm),
                    child: NewsCard(
                      news: item,
                      planet: planet,
                      compact: compact,
                      onTap: () =>
                          context.go('/main/planet/${planet.id}/news'),
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
