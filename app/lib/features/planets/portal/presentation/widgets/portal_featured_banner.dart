import 'package:flutter/material.dart';

import '../../../../../core/constants/planet_scene_theme.dart';
import '../../../../../core/theme/index.dart';
import '../../data/portal_catalog.dart';
import '../../data/universal_portal_visuals.dart';
import 'portal_glass_panel.dart';
import 'portal_network_image.dart';

class PortalFeaturedBanner extends StatelessWidget {
  const PortalFeaturedBanner({
    super.key,
    required this.planetId,
    this.onTap,
  });

  final String planetId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool narrow = constraints.maxWidth < 560;
        final double height = narrow ? 190 : 220;
        final IconData icon =
            themeForScene(PortalCatalog.planet(planetId).scene).coverIcon;
        final String? localImage = PortalVisuals.localFeaturedImage(planetId);

        return PortalGlassPanel(
          key: ValueKey<String>('portal-featured-banner-$planetId'),
          height: height,
          padding: EdgeInsets.zero,
          radius: 20,
          onTap: onTap,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: localImage == null
                      ? PortalNetworkImage(
                          url: PortalVisuals.photo(
                            PortalVisuals.featured(planetId),
                            width: 1200,
                          ),
                          icon: icon,
                        )
                      : Image.asset(
                          localImage,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) =>
                              PortalNetworkImage(
                            url: PortalVisuals.photo(
                              PortalVisuals.featured(planetId),
                              width: 1200,
                            ),
                            icon: icon,
                          ),
                        ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        const Color(0xF2071024),
                        const Color(0xCC0B1730),
                        const Color(0x330B1730),
                      ],
                      stops: const <double>[0, 0.55, 1],
                    ),
                  ),
                ),
              ),
              if (!narrow)
                Positioned(right: 26, top: 26, child: _accent(icon)),
              Positioned(
                left: 20,
                right: narrow ? 20 : 180,
                top: 20,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: PortalCatalog.accent.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            PortalCatalog.featuredTitle(planetId),
                            style: AppTextStyles.label(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          PortalCatalog.title(planetId),
                          style: AppTextStyles.headline().copyWith(
                            fontSize: narrow ? 20 : 26,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          PortalCatalog.featuredSubtitle(planetId),
                          style: AppTextStyles.body(
                            color: const Color(0xFFD6E4FF),
                          ).copyWith(fontSize: narrow ? 12 : 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          ClipOval(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: PortalNetworkImage(
                                url: PortalVisuals.photo(
                                  'photo-1534528741775-53994a69daeb',
                                  width: 100,
                                ),
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            PortalCatalog.featuredAuthor(planetId),
                            style: AppTextStyles.caption(color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.favorite_border_rounded,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            PortalCatalog.featuredLikes,
                            style: AppTextStyles.caption(color: Colors.white70),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.comment_outlined,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            PortalCatalog.featuredComments,
                            style: AppTextStyles.caption(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _accent(IconData icon) {
    final String? localImage = PortalVisuals.localFeaturedImage(planetId);
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: PortalCatalog.cyan.withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 6,
          ),
        ],
      ),
      child: ClipOval(
        child: localImage == null
            ? PortalNetworkImage(
                url: PortalVisuals.photo(
                  PortalVisuals.accent(planetId),
                  width: 400,
                ),
                icon: icon,
              )
            : Image.asset(localImage, fit: BoxFit.cover),
      ),
    );
  }
}
