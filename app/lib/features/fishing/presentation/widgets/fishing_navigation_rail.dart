import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/index.dart';
import 'fishing_glass_panel.dart';
import 'fishing_mock_data.dart';

class FishingNavigationRail extends StatelessWidget {
  const FishingNavigationRail({
    super.key,
    this.activeLabel = 'Рыбалка',
    this.compact = false,
    this.height,
  });

  final String activeLabel;
  final bool compact;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return FishingGlassPanel(
      width: compact ? 60 : 240,
      height: height,
      padding: EdgeInsets.all(compact ? 8 : 14),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _logo(),
            SizedBox(height: compact ? 18 : 24),
            for (final FishingNavItem item in FishingMockData.navigation)
              _item(context, item),
            SizedBox(height: compact ? 12 : 16),
            _settings(context),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    final Widget mark = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: <Color>[FishingMockData.accent, FishingMockData.cyan],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: FishingMockData.accent.withValues(alpha: 0.45),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Icon(Icons.phishing_outlined, color: Colors.white),
    );

    if (compact) return Center(child: mark);

    return Row(
      children: <Widget>[
        mark,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'FishWorld',
            style: AppTextStyles.title().copyWith(
              fontSize: 17,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _item(BuildContext context, FishingNavItem item) {
    final bool active = item.label == activeLabel;
    final Color background = active
        ? FishingMockData.accent.withValues(alpha: 0.9)
        : Colors.transparent;
    final Color iconColor = active ? Colors.white : AppColors.textSecondary;

    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Tooltip(
          message: item.label,
          child: InkWell(
            key: ValueKey<String>('fishing-nav-${item.label}'),
            onTap: () => context.go(item.route),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
                border: active
                    ? null
                    : Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Center(child: Icon(item.icon, size: 20, color: iconColor)),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        key: ValueKey<String>('fishing-nav-${item.label}'),
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: active
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: <Widget>[
              Icon(item.icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.bodyBold(color: iconColor),
                ),
              ),
              if (active)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settings(BuildContext context) {
    final Widget icon = Icon(
      Icons.settings_outlined,
      size: 20,
      color: AppColors.textSecondary,
    );

    if (compact) {
      return Tooltip(
        message: 'Настройки',
        child: InkWell(
          key: const ValueKey<String>('fishing-nav-Настройки'),
          onTap: () => context.go(FishingMockData.settingsRoute),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Center(child: icon),
          ),
        ),
      );
    }

    return InkWell(
      key: const ValueKey<String>('fishing-nav-Настройки'),
      onTap: () => context.go(FishingMockData.settingsRoute),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: <Widget>[
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Настройки',
                style: AppTextStyles.bodyBold(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
