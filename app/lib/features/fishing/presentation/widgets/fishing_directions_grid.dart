import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import 'fishing_glass_panel.dart';
import 'fishing_mock_data.dart';
import 'fishing_network_image.dart';

class FishingDirectionsGrid extends StatelessWidget {
  const FishingDirectionsGrid({super.key, this.onShowAll});

  final VoidCallback? onShowAll;

  @override
  Widget build(BuildContext context) {
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
                  Text('Виды ловли', style: AppTextStyles.caption()),
                ],
              ),
            ),
            InkWell(
              key: const ValueKey<String>('fishing-show-all'),
              onTap: onShowAll,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: FishingMockData.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: FishingMockData.accent.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Все виды',
                      style: AppTextStyles.label(color: FishingMockData.cyan),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: FishingMockData.cyan,
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
              key: const ValueKey<String>('fishing-directions-grid'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 112,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: FishingMockData.directions.length,
              itemBuilder: (BuildContext context, int index) {
                final FishingDirection direction =
                    FishingMockData.directions[index];
                return _DirectionCard(
                  direction: direction,
                  assetPath: FishingMockData.localDirectionImage(index),
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
  const _DirectionCard({required this.direction, this.assetPath});

  final FishingDirection direction;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    return FishingGlassPanel(
      key: ValueKey<String>('fishing-direction-${direction.title}'),
      padding: EdgeInsets.zero,
      radius: 16,
      height: 112,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: assetPath == null
                  ? FishingNetworkImage(
                      url: FishingMockData.photo(direction.image, width: 500),
                      icon: Icons.phishing_outlined,
                    )
                  : Image.asset(
                      assetPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) => FishingNetworkImage(
                        url: FishingMockData.photo(direction.image, width: 500),
                        icon: Icons.phishing_outlined,
                      ),
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
                  direction.title,
                  style: AppTextStyles.bodyBold(color: Colors.white)
                      .copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  direction.members,
                  style: AppTextStyles.caption(color: FishingMockData.cyan)
                      .copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
