import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// Неоновый AppBar с полупрозрачным blur и линией свечения.
class NeonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NeonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showGlowLine = true,
    this.blur = 10.0,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showGlowLine;
  final double blur;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    final Widget bar = AppBar(
      title: Text(title, style: AppTextStyles.headline()),
      actions: actions,
      leading: leading,
      // На web размытие фона на части устройств даёт серый прямоугольник,
      // поэтому используем более плотный фон без BackdropFilter.
      backgroundColor: Colors.black.withValues(alpha: kIsWeb ? 0.72 : 0.4),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: showGlowLine
          ? PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pillAll,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: primary.withValues(alpha: 0.7),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: <Color>[
                      primary.withValues(alpha: 0),
                      primary,
                      primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );

    if (kIsWeb) return bar;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: bar,
      ),
    );
  }
}
