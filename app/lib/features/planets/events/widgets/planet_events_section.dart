import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import '../../../../data/models/planet_event.dart';
import '../../../../data/providers/planet_providers.dart';

/// Секция «События планеты» на экране планеты: ближайшие события и переход
/// к полному списку, где можно создать своё событие и подать заявку.
class PlanetEventsSection extends ConsumerWidget {
  const PlanetEventsSection({super.key, required this.planet, this.compact = false});

  final Planet planet;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PlanetEvent>> eventsAsync = ref.watch(
      planetEventsProvider(planet.id),
    );
    final List<PlanetEvent> events =
        eventsAsync.valueOrNull ?? const <PlanetEvent>[];

    final double spaceXs = compact ? CompactSpace.xs : AppSpacing.xs;
    final double spaceXxs = compact ? CompactSpace.xxs : AppSpacing.xxs;
    final double spaceSm = compact ? CompactSpace.sm : AppSpacing.sm;
    final double spaceMd = compact ? CompactSpace.sm : AppSpacing.md;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.event_outlined,
                size: compact ? 12 : 18, color: planet.accent),
            SizedBox(width: spaceXs),
            Expanded(
              child: Text(
                'События планеты',
                style: compact ? CompactText.title() : AppTextStyles.title(),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/main/planet/${planet.id}/events'),
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
                'Все события',
                style: (compact ? CompactText.label() : AppTextStyles.label())
                    .copyWith(color: planet.accent),
              ),
            ),
          ],
        ),
        SizedBox(height: spaceXxs),
        Text(
          'Создайте встречу или поездку — участники подадут заявки',
          style: compact ? CompactText.caption() : AppTextStyles.caption(),
        ),
        SizedBox(height: spaceSm),
        if (eventsAsync.isLoading && events.isEmpty)
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
        else if (events.isEmpty)
          NeonCard(
            color: planet.accent,
            padding: compact ? const EdgeInsets.all(6) : AppSpacing.card,
            child: Row(
              children: <Widget>[
                Icon(Icons.event_available_outlined,
                    size: compact ? 14 : 24, color: planet.accent),
                SizedBox(width: spaceSm),
                Expanded(
                  child: Text(
                    'Пока нет событий — создайте первое.',
                    style: (compact ? CompactText.body() : AppTextStyles.body())
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          )
        else
          for (final PlanetEvent event in events.take(2))
            Padding(
              padding: EdgeInsets.only(bottom: spaceSm),
              child: _EventPreviewCard(
                event: event,
                planet: planet,
                compact: compact,
                onTap: () =>
                    context.go('/main/planet/${planet.id}/events'),
              ),
            ),
      ],
    );
  }
}

class _EventPreviewCard extends StatelessWidget {
  const _EventPreviewCard({
    required this.event,
    required this.planet,
    required this.onTap,
    this.compact = false,
  });

  final PlanetEvent event;
  final Planet planet;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final String seats = event.hasLimit
        ? '${event.taken}/${event.seats}'
        : '${event.taken}';
    final double spaceSm = compact ? CompactSpace.xs : AppSpacing.sm;
    final double spaceXxs = compact ? CompactSpace.xxs : AppSpacing.xxs;
    return NeonCard(
      color: planet.accent,
      padding: compact ? const EdgeInsets.all(6) : AppSpacing.card,
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Text(event.emoji, style: TextStyle(fontSize: compact ? 14 : 26)),
          SizedBox(width: spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  event.title,
                  style:
                      compact ? CompactText.bodyBold() : AppTextStyles.bodyBold(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  <String>[
                    if (event.date.isNotEmpty) _formatDate(event.date),
                    if (event.place.isNotEmpty) event.place,
                  ].join(' · '),
                  style:
                      compact ? CompactText.caption() : AppTextStyles.caption(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: spaceSm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.groups_outlined,
                  size: compact ? 10 : 15, color: planet.accent),
              SizedBox(width: spaceXxs),
              Text(
                seats,
                style: (compact ? CompactText.label() : AppTextStyles.label())
                    .copyWith(color: planet.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDate(String iso) {
  final DateTime? date = DateTime.tryParse(iso);
  if (date == null) return iso;
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year}';
}
