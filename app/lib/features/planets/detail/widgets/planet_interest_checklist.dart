import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/planet_interest_details.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import '../../../../data/providers/planet_interest_selection_provider.dart';

class PlanetInterestChecklist extends ConsumerWidget {
  const PlanetInterestChecklist({
    super.key,
    required this.planet,
    this.title = 'Подбери, что тебя интересует',
    this.showHint = true,
    this.compact = false,
  });

  final Planet planet;
  final String title;
  final bool showHint;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PlanetInterestGroup> groups =
        planetInterestDetailsByScene[planet.scene] ??
        const <PlanetInterestGroup>[];
    if (groups.isEmpty) return const SizedBox.shrink();

    final Set<String> selected = ref.watch(
      selectedPlanetInterestsProvider(planet.id),
    );
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color color = planet.accent;
    final double spaceLg = compact ? CompactSpace.md : AppSpacing.lg;
    final double spaceMd = compact ? CompactSpace.sm : AppSpacing.md;
    final double spaceSm = compact ? CompactSpace.xs : AppSpacing.sm;
    final double spaceXs = compact ? CompactSpace.xxs : AppSpacing.xs;

    return GlassCard(
      compact: compact,
      padding: EdgeInsets.all(spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.tune_rounded, color: color, size: compact ? 14 : 22),
              SizedBox(width: spaceSm),
              Expanded(
                child: Text(
                  title,
                  style: compact
                      ? CompactText.bodyBold()
                      : AppTextStyles.bodyBold(),
                ),
              ),
            ],
          ),
          if (showHint) ...<Widget>[
            SizedBox(height: spaceXs),
            Text(
              'Отметь пункты галочками — так подбор найдёт подходящих людей точнее',
              style: compact
                  ? CompactText.caption(color: AppColors.textMuted)
                  : AppTextStyles.caption(color: AppColors.textMuted),
            ),
          ],
          SizedBox(height: spaceLg),
          for (int g = 0; g < groups.length; g++) ...<Widget>[
            if (groups[g].title != title)
              Text(
                groups[g].title,
                style:
                    compact ? CompactText.bodyBold() : AppTextStyles.bodyBold(),
              ),
            if (groups[g].title != title) SizedBox(height: spaceSm),
            for (final String item in groups[g].items)
              Padding(
                padding: EdgeInsets.only(bottom: spaceXs),
                child: InkWell(
                  key: ValueKey<String>('planet-interest-$item'),
                  borderRadius: AppRadius.mdAll,
                  onTap: () => toggleSelectedPlanetInterest(
                    ref,
                    planet.id,
                    item,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spaceMd,
                      vertical: spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: selected.contains(item)
                          ? color.withValues(alpha: 0.14)
                          : scheme.surface.withValues(alpha: 0.4),
                      borderRadius: AppRadius.mdAll,
                      border: Border.all(
                        color: selected.contains(item)
                            ? color.withValues(alpha: 0.7)
                            : scheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: compact ? 14 : 22,
                          height: compact ? 14 : 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected.contains(item)
                                ? color
                                : Colors.transparent,
                            border: Border.all(
                              color: selected.contains(item)
                                  ? color
                                  : AppColors.textMuted.withValues(alpha: 0.7),
                              width: compact ? 1.0 : 1.6,
                            ),
                          ),
                          child: selected.contains(item)
                              ? Icon(
                                  Icons.check,
                                  size: compact ? 10 : 16,
                                  color: AppColors.white,
                                )
                              : null,
                        ),
                        SizedBox(width: spaceMd),
                        Expanded(
                          child: Text(
                            item,
                            style: (compact
                                    ? CompactText.body()
                                    : AppTextStyles.body())
                                .copyWith(
                              color: selected.contains(item)
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (g < groups.length - 1) SizedBox(height: spaceLg),
          ],
        ],
      ),
    );
  }
}
