import 'package:flutter/material.dart';

import '../../../../core/constants/planet_scene_theme.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import 'planet_hero_orb.dart';
import 'planet_stat_chip.dart';

class CinemaCoverHeader extends StatelessWidget {
  const CinemaCoverHeader({
    super.key,
    required this.planet,
    required this.theme,
    required this.coverPath,
    required this.memberCount,
    required this.joined,
    required this.onJoin,
    required this.onLeave,
  });

  final Planet planet;
  final PlanetSceneTheme theme;
  final String coverPath;
  final int memberCount;
  final bool joined;
  final Future<void> Function() onJoin;
  final Future<void> Function() onLeave;

  @override
  Widget build(BuildContext context) {
    final bool isFishing = planet.id == 'p_fishing';
    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: SizedBox(
        width: double.infinity,
        height: isFishing ? 220 : 180,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              coverPath,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        planet.primary,
                        planet.secondary,
                        AppColors.background,
                      ],
                    ),
                  ),
                  child: Icon(
                    theme.coverIcon,
                    size: 40,
                    color: const Color(0x66FFFFFF),
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Color(0xF0080414),
                    Color(0xB80C061E),
                    Color(0x40080414),
                  ],
                  stops: <double>[0.0, 0.42, 1.0],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  CompactSpace.sm,
                  CompactSpace.xs,
                  CompactSpace.sm,
                  CompactSpace.xs,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: 72,
                        height: 40,
                        child: FittedBox(
                          child: PlanetHeroOrb(planet: planet, compact: true),
                        ),
                      ),
                      Text(
                        planet.shortName,
                        style: isFishing
                            ? AppTextStyles.headline()
                            : CompactText.headline(),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        planet.tagline,
                        style: isFishing
                            ? AppTextStyles.body(color: planet.accent)
                            : CompactText.body(color: planet.accent),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: CompactSpace.xxs),
                      PlanetStatChip(
                        icon: Icons.people_alt_outlined,
                        label: '$memberCount участников',
                        color: planet.accent,
                        compact: !isFishing,
                      ),
                      const SizedBox(height: CompactSpace.xs),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isFishing ? 260 : 180),
                        child: Column(
                          children: <Widget>[
                            if (joined) ...<Widget>[
                              NeonButton(
                                label: 'Вы уже присоединились',
                                icon: Icons.check_circle_outline_rounded,
                                expanded: true,
                                compact: !isFishing,
                                color: planet.accent,
                                onPressed: null,
                              ),
                              TextButton(
                                onPressed: onLeave,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isFishing ? AppSpacing.sm : CompactSpace.xs,
                                    vertical: isFishing ? AppSpacing.xxs : 0,
                                  ),
                                  minimumSize: isFishing ? null : Size.zero,
                                  tapTargetSize: isFishing
                                      ? null
                                      : MaterialTapTargetSize.shrinkWrap,
                                  textStyle: isFishing
                                      ? AppTextStyles.label()
                                      : CompactText.label(),
                                ),
                                child: const Text('Покинуть планету'),
                              ),
                            ] else
                              NeonButton(
                                label: 'Присоединиться',
                                icon: Icons.rocket_launch_outlined,
                                expanded: true,
                                compact: !isFishing,
                                color: planet.primary,
                                onPressed: onJoin,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
