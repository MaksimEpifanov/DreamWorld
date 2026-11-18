import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import 'planet_format.dart';
import 'planet_orb.dart';

/// Карточка планеты-сообщества на главном экране.
///
/// Стеклянная неоновая карточка с живым шаром планеты, названием, слоганом,
/// числом участников и стрелкой входа. Вся поверхность кликабельна, при
/// наведении появляется усиленное свечение, при нажатии — пружинистый отклик.
class PlanetCard extends StatefulWidget {
  const PlanetCard({super.key, required this.planet, this.onTap});

  final Planet planet;
  final VoidCallback? onTap;

  @override
  State<PlanetCard> createState() => _PlanetCardState();
}

class _PlanetCardState extends State<PlanetCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Planet planet = widget.planet;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedPress(
        onPressed: widget.onTap,
        scaleDown: 0.96,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgAll,
            boxShadow: _hovered
                ? <BoxShadow>[
                    BoxShadow(
                      color: planet.primary.withValues(alpha: 0.45),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: planet.secondary.withValues(alpha: 0.3),
                      blurRadius: 44,
                      spreadRadius: -6,
                    ),
                  ]
                : null,
          ),
          child: GlassCard(
            borderColor: planet.primary,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: PlanetOrb(planet: planet, size: 104),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  planet.displayName,
                  style: AppTextStyles.title().copyWith(
                    shadows: <Shadow>[
                      Shadow(
                        color: planet.primary.withValues(alpha: 0.55),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  planet.tagline,
                  style: AppTextStyles.caption(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Flexible(child: _MembersPill(planet: planet)),
                    const SizedBox(width: AppSpacing.sm),
                    _OpenDot(planet: planet),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Плашка с числом участников планеты.
class _MembersPill extends StatelessWidget {
  const _MembersPill({required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: planet.accent.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: planet.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.people_alt_rounded, size: 14, color: planet.accent),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              '${formatMemberCount(planet.memberCount)} участников',
              style: AppTextStyles.label(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Круглая неоновая стрелка входа в планету.
class _OpenDot extends StatelessWidget {
  const _OpenDot({required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: <Color>[planet.primary, planet.secondary],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: planet.primary.withValues(alpha: 0.55),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        size: 16,
        color: AppColors.white,
      ),
    );
  }
}
