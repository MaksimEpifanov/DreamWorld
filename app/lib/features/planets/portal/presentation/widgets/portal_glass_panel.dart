import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/portal_catalog.dart';

class PortalGlassPanel extends StatelessWidget {
  const PortalGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.blur = 14,
    this.color = PortalCatalog.panel,
    this.borderColor = PortalCatalog.border,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    final Widget panel = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return panel;
    return InkWell(onTap: onTap, borderRadius: borderRadius, child: panel);
  }
}
