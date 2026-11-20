import 'package:flutter/material.dart';

import '../../../../../core/constants/planet_scene_theme.dart';
import '../../../../../core/theme/index.dart';
import '../../data/portal_catalog.dart';
import '../../data/universal_portal_visuals.dart';
import 'portal_glass_panel.dart';
import 'portal_network_image.dart';

class PortalHeader extends StatelessWidget {
  const PortalHeader({
    super.key,
    required this.planetId,
    this.onSearch,
    this.onProfile,
  });

  final String planetId;
  final VoidCallback? onSearch;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool narrow = constraints.maxWidth < 520;
        final double height = narrow ? 210 : 250;
        final IconData icon =
            themeForScene(PortalCatalog.planet(planetId).scene).coverIcon;

        return PortalGlassPanel(
          key: ValueKey<String>('portal-header-$planetId'),
          height: height,
          padding: EdgeInsets.zero,
          radius: 20,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: PortalNetworkImage(
                    url: PortalVisuals.photo(
                      PortalVisuals.hero(planetId),
                      width: 1600,
                    ),
                    icon: icon,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: <Color>[
                        const Color(0xF2071024),
                        const Color(0xB30B1730),
                        const Color(0x330B1730),
                      ],
                      stops: const <double>[0, 0.55, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: narrow ? 10 : 16,
                top: narrow ? 10 : 16,
                child: Row(
                  children: <Widget>[
                    _circleButton(
                      key: ValueKey<String>('portal-search-$planetId'),
                      icon: Icons.search_rounded,
                      onTap: onSearch,
                      size: narrow ? 34 : 40,
                    ),
                    SizedBox(width: narrow ? 6 : 10),
                    _avatar(narrow ? 34 : 42),
                  ],
                ),
              ),
              Positioned(
                left: narrow ? 14 : 22,
                right: narrow ? 14 : 22,
                bottom: narrow ? 14 : 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      PortalCatalog.title(planetId),
                      style: AppTextStyles.headline().copyWith(
                        fontSize: narrow ? 24 : 34,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PortalCatalog.subtitle(planetId),
                      style: AppTextStyles.body(
                        color: const Color(0xFFD6E4FF),
                      ).copyWith(fontSize: narrow ? 12 : 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: narrow ? 10 : 14),
                    _stats(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _circleButton({
    required Key key,
    required IconData icon,
    required VoidCallback? onTap,
    required double size,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Icon(icon, size: size * 0.45, color: Colors.white),
      ),
    );
  }

  Widget _avatar(double size) {
    return InkWell(
      onTap: onProfile,
      borderRadius: BorderRadius.circular(999),
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: PortalNetworkImage(
            url: PortalVisuals.photo('photo-1534528741775-53994a69daeb', width: 140),
            icon: Icons.person_outline_rounded,
          ),
        ),
      ),
    );
  }

  Widget _stats() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _stat(
          icon: Icons.people_alt_outlined,
          text: '${PortalCatalog.members(planetId)} участников',
          color: PortalCatalog.cyan,
        ),
        _stat(
          icon: Icons.circle,
          text: 'Сейчас онлайн: ${PortalCatalog.online(planetId)}',
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _stat({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 190),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: icon == Icons.circle ? 8 : 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: AppTextStyles.caption(color: Colors.white).copyWith(
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
