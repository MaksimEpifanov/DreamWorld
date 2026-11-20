import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/planet_scene_theme.dart';
import '../../../../../core/theme/index.dart';
import '../../data/portal_catalog.dart';
import 'portal_glass_panel.dart';

class PortalNavigationRail extends StatelessWidget {
  const PortalNavigationRail({
    super.key,
    required this.planetId,
    this.activeLabel = 'Главная',
    this.compact = false,
    this.height,
  });

  final String planetId;
  final String activeLabel;
  final bool compact;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final IconData icon =
        themeForScene(PortalCatalog.planet(planetId).scene).coverIcon;
    final String base = '/main/planet/$planetId';
    final List<_NavItem> items = <_NavItem>[
      _NavItem('Главная', Icons.home_outlined, '/main'),
      _NavItem(PortalCatalog.title(planetId), icon, base),
      _NavItem(
        PortalCatalog.kindsLabel(planetId),
        Icons.explore_outlined,
        '$base/types',
      ),
      _NavItem('Новости', Icons.article_outlined, '$base/news'),
      _NavItem('Люди', Icons.people_outline, '$base/people'),
      _NavItem('События', Icons.event_outlined, '$base/events'),
      _NavItem('Карта', Icons.map_outlined, '$base/map'),
      _NavItem('Чат', Icons.chat_bubble_outline_rounded, '$base/chat'),
    ];

    return PortalGlassPanel(
      width: compact ? 60 : 240,
      height: height,
      padding: EdgeInsets.all(compact ? 8 : 14),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _logo(icon),
            SizedBox(height: compact ? 18 : 24),
            for (final _NavItem item in items) _item(context, item),
            SizedBox(height: compact ? 12 : 16),
            _settings(context),
          ],
        ),
      ),
    );
  }

  Widget _logo(IconData icon) {
    final Widget mark = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: <Color>[PortalCatalog.accent, PortalCatalog.cyan],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: PortalCatalog.accent.withValues(alpha: 0.45),
            blurRadius: 18,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white),
    );

    if (compact) return Center(child: mark);

    return Row(
      children: <Widget>[
        mark,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            PortalCatalog.title(planetId),
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

  Widget _item(BuildContext context, _NavItem item) {
    final bool active = item.label == activeLabel;
    final Color background = active
        ? PortalCatalog.accent.withValues(alpha: 0.9)
        : Colors.transparent;
    final Color iconColor = active ? Colors.white : AppColors.textSecondary;

    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Tooltip(
          message: item.label,
          child: InkWell(
            key: ValueKey<String>('portal-nav-${item.label}'),
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
        key: ValueKey<String>('portal-nav-${item.label}'),
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    style: AppTextStyles.bodyBold(color: iconColor),
                  ),
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
          key: const ValueKey<String>('portal-nav-Настройки'),
          onTap: () => context.go('/settings'),
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
      key: const ValueKey<String>('portal-nav-Настройки'),
      onTap: () => context.go('/settings'),
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

class _NavItem {
  const _NavItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
