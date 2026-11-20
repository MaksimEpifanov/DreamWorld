import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import 'fishing_glass_panel.dart';
import 'fishing_mock_data.dart';
import 'fishing_network_image.dart';

class FishingBottomBanner extends StatelessWidget {
  const FishingBottomBanner({super.key, this.onCreateEvent, this.onOpenChat});

  final VoidCallback? onCreateEvent;
  final VoidCallback? onOpenChat;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool narrow = constraints.maxWidth < 460;
        return FishingGlassPanel(
          key: const ValueKey<String>('fishing-bottom-banner'),
          padding: const EdgeInsets.all(20),
          radius: 20,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  // Здесь нужно фото ночного водоёма с палаткой/костром.
                  child: FishingNetworkImage(
                    url: FishingMockData.photo(
                      FishingMockData.bottomImage,
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
          FishingMockData.bottomTitle,
          style: AppTextStyles.title().copyWith(
            fontSize: 18,
            color: Colors.white,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          FishingMockData.bottomSubtitle,
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
        color: FishingMockData.accent,
        onPressed: onCreateEvent,
      ),
      NeonButton(
        label: 'Чат сообщества',
        icon: Icons.forum_outlined,
        variant: NeonButtonVariant.outlined,
        color: FishingMockData.cyan,
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
