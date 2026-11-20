import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/index.dart';
import '../../data/portal_catalog.dart';
import '../widgets/portal_bottom_banner.dart';
import '../widgets/portal_directions_grid.dart';
import '../widgets/portal_featured_banner.dart';
import '../widgets/portal_header.dart';
import '../widgets/portal_navigation_rail.dart';
import '../widgets/portal_right_sidebar.dart';
import '../widgets/portal_tabs.dart';

class UniversalPlanetPortalScreen extends StatefulWidget {
  const UniversalPlanetPortalScreen({super.key, required this.planetId});

  final String planetId;

  @override
  State<UniversalPlanetPortalScreen> createState() =>
      _UniversalPlanetPortalScreenState();
}

class _UniversalPlanetPortalScreenState
    extends State<UniversalPlanetPortalScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _directionsKey = GlobalKey();
  final GlobalKey _eventsKey = GlobalKey();
  final GlobalKey _peopleKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabSelected(String label) {
    final String base = '/main/planet/${widget.planetId}';
    if (label == 'Главная') {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }
    if (label == PortalCatalog.kindsLabel(widget.planetId)) {
      context.go('$base/types');
    } else if (label == 'Новости') {
      context.go('$base/news');
    } else if (label == 'Люди') {
      context.go('$base/people');
    } else if (label == 'События') {
      context.go('$base/events');
    } else if (label == 'Карта') {
      context.go('$base/map');
    } else if (label == 'Чат') {
      context.go('$base/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color tint = PortalCatalog.accent;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CosmicBackground(tint: tint, tintOpacity: 0.08),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double width = constraints.maxWidth;
                final bool compactRail = width < 900;
                final bool withSidebar = width >= 1240;
                final double maxHeight = constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : 900;
                final double railHeight = (maxHeight - 32)
                    .clamp(280.0, 600.0)
                    .toDouble();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                      child: PortalNavigationRail(
                        planetId: widget.planetId,
                        compact: compactRail,
                        height: railHeight,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        child: withSidebar ? _wideContent() : _stackedContent(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _center()),
            const SizedBox(width: 20),
            SizedBox(width: 300, child: _sidebar()),
          ],
        ),
      ),
    );
  }

  Widget _stackedContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 940),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[_center(), const SizedBox(height: 16), _sidebar()],
        ),
      ),
    );
  }

  Widget _center() {
    final String base = '/main/planet/${widget.planetId}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PortalHeader(
          planetId: widget.planetId,
          onSearch: () => context.go('/search'),
          onProfile: () => context.go('/profile'),
        ),
        const SizedBox(height: 12),
        PortalTabs(
          planetId: widget.planetId,
          onTabSelected: _onTabSelected,
        ),
        const SizedBox(height: 16),
        Container(
          key: _homeKey,
          child: PortalFeaturedBanner(
            planetId: widget.planetId,
            onTap: () => context.go('$base/news'),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          key: _directionsKey,
          child: PortalDirectionsGrid(
            planetId: widget.planetId,
            onShowAll: () => context.go('$base/types'),
          ),
        ),
        const SizedBox(height: 20),
        PortalBottomBanner(
          planetId: widget.planetId,
          onCreateEvent: () => context.go('$base/events'),
          onOpenChat: () => context.go('$base/chat'),
        ),
      ],
    );
  }

  Widget _sidebar() {
    return PortalRightSidebar(
      planetId: widget.planetId,
      eventsKey: _eventsKey,
      peopleKey: _peopleKey,
    );
  }
}
