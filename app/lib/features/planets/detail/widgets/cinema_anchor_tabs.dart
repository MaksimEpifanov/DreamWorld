import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/planet_scene_theme.dart';
import '../../../../core/theme/index.dart';
import '../../../../data/models/planet.dart';

class CinemaAnchorTabs extends StatefulWidget {
  const CinemaAnchorTabs({
    super.key,
    required this.planet,
    required this.theme,
    required this.sectionKeys,
  });

  final Planet planet;
  final PlanetSceneTheme theme;
  final Map<String, GlobalKey> sectionKeys;

  @override
  State<CinemaAnchorTabs> createState() => _CinemaAnchorTabsState();
}

class _CinemaAnchorTabsState extends State<CinemaAnchorTabs> {
  String _active = 'Главная';

  List<String> get _anchors => <String>[
    'Главная',
    widget.theme.genreAnchorLabel,
    'Новости',
    'Люди',
    'События',
    'Обсуждения',
  ];

  void _onTap(String label) {
    setState(() => _active = label);
    final BuildContext? anchorContext =
        widget.sectionKeys[label]?.currentContext;
    if (anchorContext != null) {
      Scrollable.ensureVisible(
        anchorContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
      return;
    }
    if (label == 'Карта') {
      context.go('/main/planet/${widget.planet.id}/map');
    } else if (label == 'Чат') {
      context.go('/main/planet/${widget.planet.id}/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.planet.accent;
    final bool isFishing = widget.planet.id == 'p_fishing';
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final String label in <String>[..._anchors, 'Карта', 'Чат'])
            Padding(
              padding: const EdgeInsets.only(right: CompactSpace.sm),
              child: InkWell(
                key: ValueKey<String>('cinema-tab-$label'),
                onTap: () => _onTap(label),
                borderRadius: AppRadius.pillAll,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isFishing ? AppSpacing.md : CompactSpace.sm,
                    vertical: isFishing ? AppSpacing.xs : CompactSpace.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _active == label
                        ? accent.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: AppRadius.pillAll,
                    border: Border.all(
                      color: _active == label
                          ? accent
                          : Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Text(
                    label,
                    style: isFishing
                        ? AppTextStyles.label(
                            color: _active == label
                                ? accent
                                : AppColors.textPrimary,
                          )
                        : CompactText.label(
                            color: _active == label
                                ? accent
                                : AppColors.textPrimary,
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
