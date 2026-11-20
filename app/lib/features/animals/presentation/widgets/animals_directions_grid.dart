import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import 'animals_glass_panel.dart';
import 'animals_mock_data.dart';
import 'animals_network_image.dart';

class AnimalsDirectionsGrid extends StatelessWidget {
  const AnimalsDirectionsGrid({super.key, this.onShowAll});

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
                  Text('Виды животных', style: AppTextStyles.caption()),
                ],
              ),
            ),
            InkWell(
              key: const ValueKey<String>('animals-show-all'),
              onTap: onShowAll,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AnimalsMockData.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AnimalsMockData.accent.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Все виды',
                      style: AppTextStyles.label(color: AnimalsMockData.cyan),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AnimalsMockData.cyan,
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
              key: const ValueKey<String>('animals-directions-grid'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 112,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: AnimalsMockData.directions.length,
              itemBuilder: (BuildContext context, int index) {
                final AnimalsDirection direction =
                    AnimalsMockData.directions[index];
                return _DirectionCard(direction: direction);
              },
            );
          },
        ),
      ],
    );
  }
}

class _DirectionCard extends StatelessWidget {
  const _DirectionCard({required this.direction});

  final AnimalsDirection direction;

  @override
  Widget build(BuildContext context) {
    return AnimalsGlassPanel(
      key: ValueKey<String>('animals-direction-${direction.title}'),
      padding: EdgeInsets.zero,
      radius: 16,
      height: 112,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AnimalsNetworkImage(
                url: AnimalsMockData.photo(direction.image, width: 500),
                icon: Icons.pets_outlined,
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
                  style: AppTextStyles.caption(color: AnimalsMockData.cyan)
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
