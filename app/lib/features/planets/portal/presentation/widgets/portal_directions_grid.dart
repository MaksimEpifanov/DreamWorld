import 'package:flutter/material.dart';

import '../../../../../core/constants/planet_scene_theme.dart';
import '../../../../../core/theme/index.dart';
import '../../data/portal_catalog.dart';
import '../../data/universal_portal_visuals.dart';
import 'portal_glass_panel.dart';
import 'portal_network_image.dart';

class PortalDirectionsGrid extends StatelessWidget {
  const PortalDirectionsGrid({
    super.key,
    required this.planetId,
    this.onShowAll,
  });

  final String planetId;
  final VoidCallback? onShowAll;

  @override
  Widget build(BuildContext context) {
    final IconData icon =
        themeForScene(PortalCatalog.planet(planetId).scene).coverIcon;
    final List<String> directions = PortalCatalog.directions(planetId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Направления',
                    style: AppTextStyles.title().copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    PortalCatalog.kindsLabel(planetId),
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
            ),
            InkWell(
              key: ValueKey<String>('portal-show-all-$planetId'),
              onTap: onShowAll,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: PortalCatalog.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: PortalCatalog.accent.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Все виды',
                      style: AppTextStyles.label(color: PortalCatalog.cyan),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: PortalCatalog.cyan,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int columns = constraints.maxWidth >= 700
                ? 3
                : constraints.maxWidth >= 460
                ? 2
                : 1;
            return GridView.builder(
              key: ValueKey<String>('portal-directions-grid-$planetId'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 112,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: directions.length,
              itemBuilder: (BuildContext context, int index) {
                final String? localImage =
                    PortalVisuals.localDirectionImage(planetId, index);
                return _DirectionCard(
                  title: directions[index],
                  image: PortalVisuals.photo(
                    PortalVisuals.accent(planetId),
                    width: 500,
                  ),
                  assetPath: localImage,
                  icon: icon,
                  index: index,
                  planetId: planetId,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _DirectionCard extends StatelessWidget {
  const _DirectionCard({
    required this.title,
    required this.image,
    required this.icon,
    required this.index,
    required this.planetId,
    this.assetPath,
  });

  final String title;
  final String image;
  final IconData icon;
  final int index;
  final String planetId;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    return PortalGlassPanel(
      key: ValueKey<String>('portal-direction-$planetId-$index'),
      padding: EdgeInsets.zero,
      radius: 16,
      height: 112,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: assetPath == null
                  ? PortalNetworkImage(url: image, icon: icon)
                  : Image.asset(
                      assetPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) =>
                          PortalNetworkImage(url: image, icon: icon),
                    ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    const Color(0x1A071024),
                    const Color(0xE6071024),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.bodyBold(color: Colors.white).copyWith(
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${PortalCatalog.members(planetId)} участников',
                  style: AppTextStyles.caption(
                    color: PortalCatalog.cyan,
                  ).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
