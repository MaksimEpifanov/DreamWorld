import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import 'animals_glass_panel.dart';
import 'animals_mock_data.dart';
import 'animals_network_image.dart';

class AnimalsRightSidebar extends StatefulWidget {
  const AnimalsRightSidebar({super.key, this.eventsKey, this.peopleKey});

  final GlobalKey? eventsKey;
  final GlobalKey? peopleKey;

  @override
  State<AnimalsRightSidebar> createState() => _AnimalsRightSidebarState();
}

class _AnimalsRightSidebarState extends State<AnimalsRightSidebar> {
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
              key: const ValueKey<String>('animals-popular-panel'),
              title: 'Популярные животные',
              children: <Widget>[
                for (final AnimalsPopularType type
                    in AnimalsMockData.popularTypes)
                  _popularRow(type),
              ],
            ),
            const SizedBox(height: 16),
            _panel(
              key:
                  widget.eventsKey ??
                  const ValueKey<String>('animals-events-panel'),
              title: 'Ближайшие события',
              children: <Widget>[
                for (final AnimalsEvent event in AnimalsMockData.events)
                  _eventRow(event),
              ],
            ),
            const SizedBox(height: 16),
            _panel(
              key:
                  widget.peopleKey ??
                  const ValueKey<String>('animals-people-panel'),
              title: 'Рекомендуемые люди',
              children: <Widget>[
                for (final AnimalsPerson person in AnimalsMockData.people)
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
    return AnimalsGlassPanel(
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

  Widget _popularRow(AnimalsPopularType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 42,
              height: 42,
              child: AnimalsNetworkImage(
                url: AnimalsMockData.photo(type.image, width: 160),
                icon: Icons.pets_outlined,
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
                Text('${type.members} любителей', style: AppTextStyles.caption()),
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

  Widget _eventRow(AnimalsEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AnimalsMockData.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AnimalsMockData.accent.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  event.day,
                  style: AppTextStyles.bodyBold(color: AnimalsMockData.cyan)
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
                            : AnimalsMockData.accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        event.online ? 'Онлайн' : 'Оффлайн',
                        style: AppTextStyles.caption(
                          color: event.online
                              ? AppColors.success
                              : AnimalsMockData.cyan,
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

  Widget _personRow(AnimalsPerson person) {
    final bool followed = _followed.contains(person.name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          ClipOval(
            child: SizedBox(
              width: 38,
              height: 38,
              child: AnimalsNetworkImage(
                url: AnimalsMockData.photo(person.image, width: 140),
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
            key: ValueKey<String>('animals-follow-${person.name}'),
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
                    : AnimalsMockData.accent.withValues(alpha: 0.2),
                border: Border.all(
                  color: followed
                      ? AppColors.success
                      : AnimalsMockData.accent.withValues(alpha: 0.7),
                ),
              ),
              child: Icon(
                followed ? Icons.check : Icons.add,
                size: 17,
                color: followed ? AppColors.success : AnimalsMockData.cyan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
