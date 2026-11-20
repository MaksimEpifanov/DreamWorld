import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/planet_genre_visuals.dart';
import '../../../../core/constants/planet_scene_theme.dart';
import '../../../../core/theme/index.dart';
import '../../../../data/models/planet.dart';
import '../../../../data/providers/planet_interest_selection_provider.dart';

class CinemaGenreGrid extends ConsumerWidget {
  const CinemaGenreGrid({
    super.key,
    required this.planet,
    required this.theme,
  });

  final Planet planet;
  final PlanetSceneTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PlanetGenreVisual> visuals =
        planetGenreVisualsByScene[planet.scene] ??
        const <PlanetGenreVisual>[];
    if (visuals.isEmpty) return const SizedBox.shrink();

    final Set<String> selected = ref.watch(
      selectedPlanetInterestsProvider(planet.id),
    );
    final bool isFishing = planet.id == 'p_fishing';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.grid_view_rounded,
                size: isFishing ? 22 : 12, color: planet.accent),
            const SizedBox(width: CompactSpace.xs),
            Text(
              theme.genreSectionTitle,
              style: isFishing ? AppTextStyles.display() : CompactText.title(),
            ),
          ],
        ),
        const SizedBox(height: CompactSpace.sm),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (isFishing) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 170,
                  mainAxisExtent: 110,
                  crossAxisSpacing: CompactSpace.xs,
                  mainAxisSpacing: CompactSpace.xs,
                ),
                itemCount: visuals.length,
                itemBuilder: (BuildContext context, int index) => _GenreCard(
                  planet: planet,
                  visual: visuals[index],
                  tintIndex: index,
                  selected: selected.contains(visuals[index].fullItem),
                  largeLabels: true,
                  onTap: () => toggleSelectedPlanetInterest(
                    ref,
                    planet.id,
                    visuals[index].fullItem,
                  ),
                ),
              );
            }
            final int columns = constraints.maxWidth >= 600 ? 3 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: CompactSpace.xxs,
              mainAxisSpacing: CompactSpace.xxs,
              childAspectRatio: 1.2,
              children: <Widget>[
                for (int index = 0; index < visuals.length; index++)
                  _GenreCard(
                    planet: planet,
                    visual: visuals[index],
                    tintIndex: index,
                    selected: selected.contains(visuals[index].fullItem),
                    onTap: () => toggleSelectedPlanetInterest(
                      ref,
                      planet.id,
                      visuals[index].fullItem,
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

class _GenreCard extends StatelessWidget {
  const _GenreCard({
    required this.planet,
    required this.visual,
    required this.tintIndex,
    required this.selected,
    required this.onTap,
    this.largeLabels = false,
  });

  final Planet planet;
  final PlanetGenreVisual visual;
  final int tintIndex;
  final bool selected;
  final VoidCallback onTap;
  final bool largeLabels;

  @override
  Widget build(BuildContext context) {
    final List<Color> palette = <Color>[
      planet.primary,
      planet.secondary,
      planet.accent,
    ];
    final int paletteIndex = tintIndex % palette.length;
    final Color tint = palette[paletteIndex];
    final Color shade = Color.lerp(
      const Color(0xFF07060D),
      tint,
      0.28 + paletteIndex * 0.09,
    )!;

    return InkWell(
      key: ValueKey<String>('cinema-genre-${visual.shortLabel}'),
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: SizedBox(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                visual.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) {
                  final String? cover = planetCoverByPlanetId[planet.id];
                  if (cover != null && cover != visual.assetPath) {
                    return Image.asset(
                      cover,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                planet.primary,
                                planet.secondary,
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          planet.primary,
                          planet.secondary,
                        ],
                      ),
                    ),
                  );
                },
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      tint.withValues(alpha: 0.14),
                      shade.withValues(alpha: 0.86),
                    ],
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  top: CompactSpace.xs,
                  right: CompactSpace.xs,
                  child: Container(
                    width: largeLabels ? 22 : 14,
                    height: largeLabels ? 22 : 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: planet.accent,
                    ),
                    child: Icon(
                      Icons.check,
                      size: largeLabels ? 14 : 9,
                      color: AppColors.background,
                    ),
                  ),
                ),
              Positioned(
                left: CompactSpace.sm,
                right: CompactSpace.sm,
                bottom: CompactSpace.sm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      visual.emoji,
                      style: TextStyle(fontSize: largeLabels ? 32 : 12),
                    ),
                    Text(
                      visual.shortLabel,
                      style: largeLabels
                          ? AppTextStyles.headline(color: AppColors.white)
                          : CompactText.bodyBold(color: AppColors.white),
                      maxLines: largeLabels ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
