import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import '../../../../data/models/profile.dart';
import '../../../../data/providers/planet_providers.dart';
import 'planet_member_tile.dart';

class CinemaMembersSection extends ConsumerWidget {
  const CinemaMembersSection({super.key, required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Profile>> members = ref.watch(
      planetMembersProvider(planet.id),
    );
    final bool isFishing = planet.id == 'p_fishing';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.groups_outlined,
                size: isFishing ? 18 : 12, color: planet.accent),
            const SizedBox(width: CompactSpace.xs),
            Expanded(
              child: Text(
                'Рекомендуемые люди',
                style: isFishing ? AppTextStyles.title() : CompactText.title(),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/discovery'),
              child: Text(
                'Все →',
                style: CompactText.label(color: planet.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: CompactSpace.sm),
        members.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(CompactSpace.md),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (Object error, StackTrace stackTrace) => Text(
            'Не удалось загрузить участников',
            style: CompactText.body(color: AppColors.textMuted),
          ),
          data: (List<Profile> list) {
            if (list.isEmpty) {
              return Text(
                'Пока никто не вступил. Станьте первым участником — '
                'и другие смогут найти вас здесь.',
                style: CompactText.body(color: AppColors.textSecondary),
              );
            }
            return Column(
              children: <Widget>[
                for (final Profile profile in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: CompactSpace.sm),
                    child: PlanetMemberTile(profile: profile, compact: true),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: CompactSpace.sm),
        NeonButton(
          label: 'Смотреть всех в подборе',
          icon: Icons.explore_outlined,
          variant: NeonButtonVariant.outlined,
          expanded: true,
          compact: !isFishing,
          color: planet.secondary,
          onPressed: () => context.go('/discovery'),
        ),
      ],
    );
  }
}
