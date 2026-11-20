import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';

class PlanetStatChip extends StatelessWidget {
  const PlanetStatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.outlined = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool outlined;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? CompactSpace.xs : AppSpacing.md,
        vertical: compact ? CompactSpace.xxs : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: outlined ? 0.06 : 0.12),
        borderRadius: AppRadius.pillAll,
        border: Border.all(
          color: color.withValues(alpha: outlined ? 0.5 : 0.32),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: compact ? 9 : 15, color: color),
          SizedBox(width: compact ? CompactSpace.xxs : AppSpacing.xs),
          Text(
            label,
            style: compact
                ? CompactText.label()
                : AppTextStyles.label(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
