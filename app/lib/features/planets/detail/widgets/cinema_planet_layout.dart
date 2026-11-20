import 'package:flutter/material.dart';

import '../../../../core/constants/planet_scene_theme.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import '../../events/widgets/planet_events_section.dart';
import '../../news/widgets/news_section.dart';
import 'cinema_anchor_tabs.dart';
import 'cinema_bottom_banner.dart';
import 'cinema_cover_header.dart';
import 'cinema_featured_news.dart';
import 'cinema_genre_grid.dart';
import 'cinema_members_section.dart';
import 'planet_interest_checklist.dart';

class CinemaPlanetLayout extends StatefulWidget {
  const CinemaPlanetLayout({
    super.key,
    required this.planet,
    required this.theme,
    required this.coverPath,
    required this.memberCount,
    required this.joined,
    required this.onJoin,
    required this.onLeave,
  });

  final Planet planet;
  final PlanetSceneTheme theme;
  final String coverPath;
  final int memberCount;
  final bool joined;
  final Future<void> Function() onJoin;
  final Future<void> Function() onLeave;

  @override
  State<CinemaPlanetLayout> createState() => _CinemaPlanetLayoutState();
}

class _CinemaPlanetLayoutState extends State<CinemaPlanetLayout> {
  final Map<String, GlobalKey> _sectionKeys = <String, GlobalKey>{
    'home': GlobalKey(),
    'genres': GlobalKey(),
    'news': GlobalKey(),
    'events': GlobalKey(),
    'people': GlobalKey(),
  };

  Map<String, GlobalKey> get _tabsSectionKeys => <String, GlobalKey>{
    'Главная': _sectionKeys['home']!,
    widget.theme.genreAnchorLabel: _sectionKeys['genres']!,
    'Новости': _sectionKeys['news']!,
    'Люди': _sectionKeys['people']!,
    'События': _sectionKeys['events']!,
  };

  Widget _section(String id, Widget child) =>
      Container(key: _sectionKeys[id], child: child);

  @override
  Widget build(BuildContext context) {
    final Planet planet = widget.planet;
    final PlanetSceneTheme theme = widget.theme;
    final bool isFishing = planet.id == 'p_fishing';

    final Widget header = _section(
      'home',
      CinemaCoverHeader(
        planet: planet,
        theme: theme,
        coverPath: widget.coverPath,
        memberCount: widget.memberCount,
        joined: widget.joined,
        onJoin: widget.onJoin,
        onLeave: widget.onLeave,
      ),
    );
    final Widget tabs = CinemaAnchorTabs(
      planet: planet,
      theme: theme,
      sectionKeys: _tabsSectionKeys,
    );
    final Widget featured = CinemaFeaturedNews(planet: planet, theme: theme);
    final Widget genres = _section(
      'genres',
      CinemaGenreGrid(planet: planet, theme: theme),
    );
    final Widget checklist = PlanetInterestChecklist(
      planet: planet,
      title: theme.checklistTitle,
      showHint: false,
      compact: true,
    );
    final Widget news = _section(
      'news',
      NewsSection(planet: planet, compact: true),
    );
    final Widget events = _section(
      'events',
      PlanetEventsSection(planet: planet, compact: true),
    );
    final Widget people = _section(
      'people',
      CinemaMembersSection(planet: planet),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 1100;

        final List<Widget> content = <Widget>[
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      header,
                      const SizedBox(height: CompactSpace.md),
                      tabs,
                      const SizedBox(height: CompactSpace.md),
                      featured,
                      const SizedBox(height: CompactSpace.md),
                      genres,
                      const SizedBox(height: CompactSpace.md),
                      news,
                    ],
                  ),
                ),
                SizedBox(width: isFishing ? CompactSpace.xxl : CompactSpace.md),
                SizedBox(
                  width: isFishing ? 320 : 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      checklist,
                      const SizedBox(height: CompactSpace.md),
                      events,
                      const SizedBox(height: CompactSpace.md),
                      people,
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                header,
                const SizedBox(height: CompactSpace.lg),
                tabs,
                const SizedBox(height: CompactSpace.lg),
                featured,
                const SizedBox(height: CompactSpace.lg),
                genres,
                const SizedBox(height: CompactSpace.lg),
                checklist,
                const SizedBox(height: CompactSpace.lg),
                news,
                const SizedBox(height: CompactSpace.lg),
                events,
                const SizedBox(height: CompactSpace.lg),
                people,
              ],
            ),
          const SizedBox(height: CompactSpace.lg),
          CinemaBottomBanner(planet: planet, theme: theme),
          const SizedBox(height: CompactSpace.lg),
        ];

        return ResponsiveContent(
          maxWidth: isFishing ? 1280 : 1600,
          child: SingleChildScrollView(
            padding: CompactSpace.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
        );
      },
    );
  }
}
