import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import 'fishing_glass_panel.dart';
import 'fishing_mock_data.dart';
import 'fishing_network_image.dart';

class FishingRightSidebar extends StatefulWidget {
  const FishingRightSidebar({super.key, this.eventsKey, this.peopleKey});

  final GlobalKey? eventsKey;
  final GlobalKey? peopleKey;

  @override
  State<FishingRightSidebar> createState() => _FishingRightSidebarState();
}

class _FishingRightSidebarState extends State<FishingRightSidebar> {
  final Set<String> _followed = <String>{};

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _panel(
              key: const ValueKey<String>('fishing-popular-panel'),
              title: 'Популярные снасти',
              children: <Widget>[
                for (int index = 0;
                    index < FishingMockData.popularTypes.length;
                    index++)
                  _popularRow(
                    FishingMockData.popularTypes[index],
                    assetPath: FishingMockData.localDirectionImage(index),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _panel(
              key:
                  widget.eventsKey ??
                  const ValueKey<String>('fishing-events-panel'),
              title: 'Ближайшие события',
              children: <Widget>[
                for (final FishingEvent event in FishingMockData.events)
                  _eventRow(event),
              ],
            ),
            const SizedBox(height: 16),
            _panel(
              key:
                  widget.peopleKey ??
                  const ValueKey<String>('fishing-people-panel'),
              title: 'Рекомендуемые люди',
              children: <Widget>[
                for (final FishingPerson person in FishingMockData.people)
                  _personRow(person),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _panel({
    required Key key,
    required String title,
    required List<Widget> children,
  }) {
    return FishingGlassPanel(
      key: key,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTextStyles.title().copyWith(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _popularRow(FishingPopularType type, {String? assetPath}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 42,
              height: 42,
              child: assetPath == null
                  ? FishingNetworkImage(
                      url: FishingMockData.photo(type.image, width: 160),
                      icon: Icons.phishing_outlined,
                    )
                  : Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) => FishingNetworkImage(
                        url: FishingMockData.photo(type.image, width: 160),
                        icon: Icons.phishing_outlined,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  type.title,
                  style: AppTextStyles.bodyBold(color: Colors.white)
                      .copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('${type.members} рыбаков', style: AppTextStyles.caption()),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _eventRow(FishingEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: FishingMockData.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: FishingMockData.accent.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  event.day,
                  style: AppTextStyles.bodyBold(color: FishingMockData.cyan)
                      .copyWith(fontSize: 16),
                ),
                Text(
                  event.month,
                  style: AppTextStyles.caption().copyWith(fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  event.title,
                  style: AppTextStyles.bodyBold(color: Colors.white)
                      .copyWith(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: <Widget>[
                    Text(event.time, style: AppTextStyles.caption()),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: event.online
                            ? AppColors.success.withValues(alpha: 0.16)
                            : FishingMockData.accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        event.online ? 'Онлайн' : 'Оффлайн',
                        style: AppTextStyles.caption(
                          color: event.online
                              ? AppColors.success
                              : FishingMockData.cyan,
                        ).copyWith(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _personRow(FishingPerson person) {
    final bool followed = _followed.contains(person.name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          ClipOval(
            child: SizedBox(
              width: 38,
              height: 38,
              // Здесь нужно фото конкретного рыбака для рекомендаций.
              child: FishingNetworkImage(
                url: FishingMockData.photo(person.image, width: 140),
                icon: Icons.person_outline_rounded,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              person.name,
              style: AppTextStyles.bodyBold(color: Colors.white)
                  .copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            key: ValueKey<String>('fishing-follow-${person.name}'),
            onTap: () {
              setState(() {
                if (followed) {
                  _followed.remove(person.name);
                } else {
                  _followed.add(person.name);
                }
              });
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: followed
                    ? AppColors.success.withValues(alpha: 0.2)
                    : FishingMockData.accent.withValues(alpha: 0.2),
                border: Border.all(
                  color: followed
                      ? AppColors.success
                      : FishingMockData.accent.withValues(alpha: 0.7),
                ),
              ),
              child: Icon(
                followed ? Icons.check : Icons.add,
                size: 17,
                color: followed ? AppColors.success : FishingMockData.cyan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
