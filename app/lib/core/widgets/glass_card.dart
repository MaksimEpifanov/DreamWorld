import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Полупрозрачная стеклянная карточка с градиентной неоновой рамкой и blur.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.borderRadius = AppRadius.lgAll,
    this.blur = 12.0,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blur;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;
    final Color secondary = theme.colorScheme.secondary;
    final Color surface = backgroundColor ?? theme.colorScheme.surface;
    // На web `BackdropFilter` на части устройств (особенно с программным
    // WebGL) отрисовывается серым прямоугольником вместо размытия, поэтому
    // вместо размытия используем более плотный фон.
    final bool frosted = blur > 0 && !kIsWeb;
    final double topAlpha = frosted ? 0.75 : (blur > 0 ? 0.86 : 0.9);
    final double bottomAlpha = frosted ? 0.5 : (blur > 0 ? 0.68 : 0.72);

    final Widget inner = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            surface.withValues(alpha: topAlpha),
            surface.withValues(alpha: bottomAlpha),
          ],
        ),
        borderRadius: borderRadius,
      ),
      padding: padding,
      child: child,
    );

    final Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            borderColor ?? primary.withValues(alpha: 0.9),
            secondary.withValues(alpha: 0.7),
            borderColor ?? primary.withValues(alpha: 0.5),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: frosted
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: inner,
              )
            : inner,
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}
