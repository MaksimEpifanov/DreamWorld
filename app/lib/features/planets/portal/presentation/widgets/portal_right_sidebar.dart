import 'package:flutter/material.dart';

import '../../../../../core/theme/index.dart';
import '../../data/portal_catalog.dart';
import '../../data/universal_portal_visuals.dart';
import 'portal_glass_panel.dart';
import 'portal_network_image.dart';

class PortalRightSidebar extends StatefulWidget {
  const PortalRightSidebar({
    super.key,
    required this.planetId,
    this.eventsKey,
    this.peopleKey,
  });

  final String planetId;
  final GlobalKey? eventsKey;
  final GlobalKey? peopleKey;

  @override
  State<PortalRightSidebar> createState() => _PortalRightSidebarState();
}

class _PortalRightSidebarState extends State<PortalRightSidebar> {
  final Set<String> _followed = <String>{};

  @override
  Widget build(BuildContext context) {
    final List<String> directions = PortalCatalog.directions(widget.planetId);
    final List<String> people = <String>[
      PortalCatalog.featuredAuthor(widget.planetId),
      'Участник_${PortalCatalog.title(widget.planetId)}',
      'Автор_Мира',
      'Друг_Сообщества',
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _panel(
              key: ValueKey<String>('portal-popular-panel-${widget.planetId}'),
              title: 'Популярные темы',
              children: <Widget>[
                for (int i = 0; i < directions.length && i < 5; i++)
                  _popularRow(directions[i], i),
              ],
            ),
            const SizedBox(height: 16),
            _panel(
              key: widget.eventsKey ??
                  ValueKey<String>('portal-events-panel-${widget.planetId}'),
              title: 'Ближайшие события',
              children: <Widget>[
                _eventRow('22', 'НОЯ', 'Встреча сообщества', '12:00', true),
                _eventRow('26', 'НОЯ', 'Мастер-класс', '15:00', false),
                _eventRow('03', 'ДЕК', 'Общий сбор', '10:30', false),
              ],
            ),
            const SizedBox(height: 16),
            _panel(
              key: widget.peopleKey ??
                  ValueKey<String>('portal-people-panel-${widget.planetId}'),
              title: 'Рекомендуемые люди',
              children: <Widget>[
                for (final String person in people) _personRow(person),
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
    return PortalGlassPanel(
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

  Widget _popularRow(String title, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 42,
              height: 42,
              child: _PopularTopicImage(
                planetId: widget.planetId,
                index: index,
                url: PortalVisuals.photo(
                  PortalVisuals.hero(widget.planetId),
                  width: 160,
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
                  title,
                  style: AppTextStyles.bodyBold(color: Colors.white).copyWith(
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${PortalCatalog.online(widget.planetId)} любителей',
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _eventRow(
    String day,
    String month,
    String title,
    String time,
    bool online,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: PortalCatalog.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: PortalCatalog.accent.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  day,
                  style: AppTextStyles.bodyBold(
                    color: PortalCatalog.cyan,
                  ).copyWith(fontSize: 16),
                ),
                Text(
                  month,
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
                  title,
                  style: AppTextStyles.bodyBold(color: Colors.white).copyWith(
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: <Widget>[
                    Text(time, style: AppTextStyles.caption()),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: online
                            ? AppColors.success.withValues(alpha: 0.16)
                            : PortalCatalog.accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        online ? 'Онлайн' : 'Оффлайн',
                        style: AppTextStyles.caption(
                          color: online
                              ? AppColors.success
                              : PortalCatalog.cyan,
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

  Widget _personRow(String name) {
    final bool followed = _followed.contains(name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          ClipOval(
            child: SizedBox(
              width: 38,
              height: 38,
              child: PortalNetworkImage(
                url: PortalVisuals.photo(
                  'photo-1534528741775-53994a69daeb',
                  width: 140,
                ),
                icon: Icons.person_outline_rounded,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodyBold(color: Colors.white).copyWith(
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            key: ValueKey<String>(
              'portal-follow-${widget.planetId}-$name',
            ),
            onTap: () {
              setState(() {
                if (followed) {
                  _followed.remove(name);
                } else {
                  _followed.add(name);
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
                    : PortalCatalog.accent.withValues(alpha: 0.2),
                border: Border.all(
                  color: followed
                      ? AppColors.success
                      : PortalCatalog.accent.withValues(alpha: 0.7),
                ),
              ),
              child: Icon(
                followed ? Icons.check : Icons.add,
                size: 17,
                color: followed ? AppColors.success : PortalCatalog.cyan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularTopicImage extends StatelessWidget {
  const _PopularTopicImage({
    required this.planetId,
    required this.index,
    required this.url,
  });

  final String planetId;
  final int index;
  final String url;

  @override
  Widget build(BuildContext context) {
    final String? assetPath =
        PortalVisuals.localDirectionImage(planetId, index);
    if (assetPath == null) {
      return PortalNetworkImage(
        url: url,
        icon: Icons.explore_outlined,
      );
    }
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) =>
          PortalNetworkImage(
        url: url,
        icon: Icons.explore_outlined,
      ),
    );
  }
}
