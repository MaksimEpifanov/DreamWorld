import 'package:flutter/material.dart';

import '../../../../../core/theme/index.dart';
import '../../../../../core/widgets/index.dart';
import '../../data/portal_catalog.dart';
import '../../data/universal_portal_visuals.dart';
import 'portal_glass_panel.dart';
import 'portal_network_image.dart';

class PortalBottomBanner extends StatelessWidget {
  const PortalBottomBanner({
    super.key,
    required this.planetId,
    this.onCreateEvent,
    this.onOpenChat,
    this.onOpenDiscussions,
  });

  final String planetId;
  final VoidCallback? onCreateEvent;
  final VoidCallback? onOpenChat;
  final VoidCallback? onOpenDiscussions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool narrow = constraints.maxWidth < 460;
        return PortalGlassPanel(
          key: ValueKey<String>('portal-bottom-banner-$planetId'),
          padding: const EdgeInsets.all(20),
          radius: 20,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: PortalNetworkImage(
                    url: PortalVisuals.photo(
                      PortalVisuals.bottom(planetId),
                      width: 1200,
                    ),
                    icon: Icons.nightlight_round_outlined,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xD60A1226),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: narrow ? 210 : 130),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: narrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _text(),
                            const SizedBox(height: 14),
                            _buttons(column: true),
                          ],
                        )
                      : Row(
                          children: <Widget>[
                            Expanded(child: _text()),
                            const SizedBox(width: 16),
                            _buttons(column: false),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _text() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          PortalCatalog.bottomTitle(planetId),
          style: AppTextStyles.title().copyWith(
            fontSize: 18,
            color: Colors.white,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          PortalCatalog.bottomSubtitle(planetId),
          style: AppTextStyles.caption(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buttons({required bool column}) {
    final List<Widget> buttons = <Widget>[
      NeonButton(
        label: 'Создать событие',
        icon: Icons.event_outlined,
        color: PortalCatalog.accent,
        onPressed: onCreateEvent,
      ),
      NeonButton(
        label: 'Обсуждения',
        icon: Icons.add_comment_outlined,
        variant: NeonButtonVariant.outlined,
        color: PortalCatalog.cyan,
        onPressed: onOpenDiscussions,
      ),
      NeonButton(
        label: 'Чат сообщества',
        icon: Icons.forum_outlined,
        variant: NeonButtonVariant.ghost,
        color: PortalCatalog.cyan,
        onPressed: onOpenChat,
      ),
    ];

    if (column) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final Widget button in buttons) ...<Widget>[
            button,
            const SizedBox(height: 8),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final Widget button in buttons) ...<Widget>[
          SizedBox(width: 180, child: button),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
