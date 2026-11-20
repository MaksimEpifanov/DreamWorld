import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/index.dart';
import '../widgets/fishing_bottom_banner.dart';
import '../widgets/fishing_directions_grid.dart';
import '../widgets/fishing_featured_banner.dart';
import '../widgets/fishing_header.dart';
import '../widgets/fishing_mock_data.dart';
import '../widgets/fishing_navigation_rail.dart';
import '../widgets/fishing_right_sidebar.dart';
import '../widgets/fishing_tabs.dart';

class FishingScreen extends StatefulWidget {
  const FishingScreen({super.key});

  @override
  State<FishingScreen> createState() => _FishingScreenState();
}

class _FishingScreenState extends State<FishingScreen> {
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
    switch (label) {
      case 'Главная':
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      case 'Виды ловли':
        context.go('/main/planet/p_fishing/types');
      case 'Новости':
        context.go('/main/planet/p_fishing/news');
      case 'Люди':
        context.go('/main/planet/p_fishing/people');
      case 'События':
        context.go('/main/planet/p_fishing/events');
      case 'Карта':
        context.go('/main/planet/p_fishing/map');
      case 'Чат':
        context.go('/main/planet/p_fishing/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: CosmicBackground(
              tint: FishingMockData.accent,
              tintOpacity: 0.08,
            ),
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
                      child: FishingNavigationRail(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FishingHeader(
          onSearch: () => context.go('/search'),
          onProfile: () => context.go('/profile'),
        ),
        const SizedBox(height: 12),
        FishingTabs(onTabSelected: _onTabSelected),
        const SizedBox(height: 16),
        Container(
          key: _homeKey,
          child: FishingFeaturedBanner(
            onTap: () => context.go('/main/planet/p_fishing/news'),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          key: _directionsKey,
          child: FishingDirectionsGrid(
            onShowAll: () => context.go('/main/planet/p_fishing/types'),
          ),
        ),
        const SizedBox(height: 20),
        FishingBottomBanner(
          onCreateEvent: () => context.go('/main/planet/p_fishing/events'),
          onOpenChat: () => context.go('/main/planet/p_fishing/chat'),
        ),
      ],
    );
  }

  Widget _sidebar() {
    return FishingRightSidebar(eventsKey: _eventsKey, peopleKey: _peopleKey);
  }
}
