import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/planet.dart';
import '../../../data/models/planet_news.dart';
import '../../../data/providers/planet_providers.dart';
import 'widgets/news_card.dart';

/// Полная лента новостей планеты.
class PlanetNewsScreen extends ConsumerWidget {
  const PlanetNewsScreen({super.key, required this.planetId});

  final String planetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Planet? planet = ref.watch(planetByIdProvider(planetId));

    if (planet == null) {
      return Scaffold(
        appBar: NeonAppBar(
          title: 'Новости',
          leading: BackButton(
            onPressed: () => context.go('/main/planet/$planetId'),
          ),
        ),
        body: const Center(child: Text('Планета не найдена')),
      );
    }

    final AsyncValue<List<PlanetNewsItem>> newsAsync = ref.watch(
      planetNewsProvider(planetId),
    );

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Новости · ${planet.displayName}',
        leading: BackButton(
          onPressed: () => context.go('/main/planet/${planet.id}'),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: newsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) => const Center(
              child: Text('Не удалось загрузить новости'),
            ),
            data: (List<PlanetNewsItem> news) {
              if (news.isEmpty) {
                return const Center(child: Text('Пока нет новостей'));
              }
              return ListView(
                padding: AppSpacing.page,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: planet.accent,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Лента обновляется каждый час',
                          style: AppTextStyles.caption(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final PlanetNewsItem item in news)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: NewsCard(
                        news: item,
                        planet: planet,
                        onTap: () => showNewsSheet(
                          context,
                          news: item,
                          planet: planet,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Открывает нижнюю панель с полным текстом новости.
Future<void> showNewsSheet(
  BuildContext context, {
  required PlanetNewsItem news,
  required Planet planet,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          border: Border(
            top: BorderSide(color: planet.accent.withValues(alpha: 0.4)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: AppSpacing.page,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(news.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: AppSpacing.sm),
                Text(news.title, style: AppTextStyles.title()),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${news.sourceName} · ${relativeTime(news.publishedAt)}',
                  style: AppTextStyles.caption(),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  news.summary,
                  style: AppTextStyles.body(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: planet.accent.withValues(alpha: 0.12),
                        borderRadius: AppRadius.pillAll,
                      ),
                      child: Text(
                        '#${news.tag}',
                        style: AppTextStyles.label(color: planet.accent),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text('${news.likes}', style: AppTextStyles.caption()),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      );
    },
  );
}
