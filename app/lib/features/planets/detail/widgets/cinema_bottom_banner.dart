import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/planet_scene_theme.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';

class CinemaBottomBanner extends StatelessWidget {
  const CinemaBottomBanner({
    super.key,
    required this.planet,
    required this.theme,
  });

  final Planet planet;
  final PlanetSceneTheme theme;

  @override
  Widget build(BuildContext context) {
    final bool isFishing = planet.id == 'p_fishing';
    return GlassCard(
      compact: !isFishing,
      backgroundColor: planet.primary.withValues(alpha: 0.18),
      child: Column(
        children: <Widget>[
          Text(
            theme.bannerHeadline,
            style: isFishing ? AppTextStyles.headline() : CompactText.headline(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: CompactSpace.xs),
          Text(
            theme.bannerSubtitle,
            style: isFishing
                ? AppTextStyles.body(color: AppColors.textSecondary)
                : CompactText.body(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: CompactSpace.lg),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final List<Widget> buttons = <Widget>[
                NeonButton(
                  label: 'Создать событие',
                  icon: Icons.event_outlined,
                  color: planet.accent,
                  compact: !isFishing,
                  onPressed: () =>
                      context.go('/main/planet/${planet.id}/events'),
                ),
                NeonButton(
                  label: 'Чат сообщества',
                  icon: Icons.forum_outlined,
                  variant: NeonButtonVariant.outlined,
                  color: planet.secondary,
                  compact: !isFishing,
                  onPressed: () =>
                      context.go('/main/planet/${planet.id}/chat'),
                ),
                NeonButton(
                  label: 'Карта планеты',
                  icon: Icons.map_outlined,
                  variant: NeonButtonVariant.outlined,
                  color: planet.primary,
                  compact: !isFishing,
                  onPressed: () =>
                      context.go('/main/planet/${planet.id}/map'),
                ),
              ];
              if (constraints.maxWidth >= 700) {
                return Row(
                  children: <Widget>[
                    for (final Widget button in buttons)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: CompactSpace.xs,
                          ),
                          child: button,
                        ),
                      ),
                  ],
                );
              }
              return Column(
                children: <Widget>[
                  for (final Widget button in buttons)
                    Padding(
                      padding: const EdgeInsets.only(bottom: CompactSpace.sm),
                      child: SizedBox(width: double.infinity, child: button),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
