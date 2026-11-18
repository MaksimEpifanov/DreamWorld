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
  const PlanetEventsSection({super.key, required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PlanetEvent>> eventsAsync = ref.watch(
      planetEventsProvider(planet.id),
    );
    final List<PlanetEvent> events =
        eventsAsync.valueOrNull ?? const <PlanetEvent>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.event_outlined, size: 18, color: planet.accent),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text('События планеты', style: AppTextStyles.title()),
            ),
            TextButton(
              onPressed: () =>
                  context.go('/main/planet/${planet.id}/events'),
              child: Text(
                'Все события',
                style: AppTextStyles.label(color: planet.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Создайте встречу или поездку — участники подадут заявки',
          style: AppTextStyles.caption(),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (eventsAsync.isLoading && events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (events.isEmpty)
          NeonCard(
            color: planet.accent,
            child: Row(
              children: <Widget>[
                Icon(Icons.event_available_outlined, color: planet.accent),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Пока нет событий — создайте первое.',
                    style: AppTextStyles.body(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          )
        else
          for (final PlanetEvent event in events.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _EventPreviewCard(
                event: event,
                planet: planet,
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
  });

  final PlanetEvent event;
  final Planet planet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String seats = event.hasLimit
        ? '${event.taken}/${event.seats}'
        : '${event.taken}';
    return NeonCard(
      color: planet.accent,
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Text(event.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  event.title,
                  style: AppTextStyles.bodyBold(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  <String>[
                    if (event.date.isNotEmpty) _formatDate(event.date),
                    if (event.place.isNotEmpty) event.place,
                  ].join(' · '),
                  style: AppTextStyles.caption(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.groups_outlined, size: 15, color: planet.accent),
              const SizedBox(width: AppSpacing.xxs),
              Text(seats, style: AppTextStyles.label(color: planet.accent)),
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
