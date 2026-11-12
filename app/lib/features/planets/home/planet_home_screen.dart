import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/planet.dart';
import '../../../data/models/profile.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/planet_providers.dart';
import 'widgets/galactic_home_system.dart';

/// Главный экран «Галактика возможностей».
class PlanetHomeScreen extends ConsumerStatefulWidget {
  const PlanetHomeScreen({super.key});

  @override
  ConsumerState<PlanetHomeScreen> createState() => _PlanetHomeScreenState();
}

class _PlanetHomeScreenState extends ConsumerState<PlanetHomeScreen> {
  final Set<String> _dismissedCards = <String>{};
  bool _interestCardDismissed = false;

  @override
  Widget build(BuildContext context) {
    final List<Planet> planets = ref.watch(planetsProvider);
    return SafeArea(
      child: Column(
        children: <Widget>[
          const _GalaxyHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 900;
                final bool showBottomCards =
                    wide && constraints.maxHeight >= 620;
                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned.fill(
                      child: GalacticHomeSystem(
                        planets: planets,
                        bottomReservedSpace: showBottomCards ? 132 : 0,
                        onPlanetTap: (Planet planet) =>
                            context.go('/main/planet/${planet.id}'),
                      ),
                    ),
                    if (wide && !_interestCardDismissed)
                      Positioned(
                        left: 18,
                        top: 18,
                        width: 238,
                        child: _GlassPanel(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const _RoundIcon(
                                      icon: Icons.people_alt_rounded,
                                      color: Color(0xFF20BFFF),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Найди своих по интересам',
                                            style: AppTextStyles.label(
                                              color: AppColors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Люди, близкие тебе по увлечениям и взглядам',
                                            style: AppTextStyles.caption(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          NeonButton(
                                            label: 'Перейти',
                                            onPressed: () =>
                                                context.go('/discovery'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: -8,
                                right: -8,
                                child: _CloseCardButton(
                                  title: 'Найди своих по интересам',
                                  onPressed: () => setState(
                                    () => _interestCardDismissed = true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (showBottomCards)
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 14,
                        height: 112,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _bottomCards(context),
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

  List<Widget> _bottomCards(BuildContext context) {
    final List<Widget> cards = <Widget>[];
    if (!_dismissedCards.contains('stories')) {
      cards.add(
        SizedBox(
          width: 218,
          child: _GalaxyInfoCard(
            icon: Icons.auto_awesome_rounded,
            title: '21 планета — тысячи историй',
            description: 'Выбирай то, что вдохновляет. На каждой планете — люди, события и новые возможности.',
            onClose: () => _dismiss('stories'),
          ),
        ),
      );
    }
    if (!_dismissedCards.contains('popular')) {
      cards.add(
        Expanded(
          child: _GalaxyActionCard(
            icon: Icons.groups_rounded,
            title: 'Популярные планеты',
            subtitle: 'Сейчас на пике интереса',
            accent: const Color(0xFF9B8CFF),
            artwork: _PlanetMiniArtwork(),
            onTap: () => context.go('/main/planets'),
            onClose: () => _dismiss('popular'),
          ),
        ),
      );
    }
    if (!_dismissedCards.contains('people')) {
      cards.add(
        Expanded(
          child: _GalaxyActionCard(
            icon: Icons.star_rounded,
            title: 'Новые люди',
            subtitle: 'Кто-то уже ждёт тебя',
            accent: const Color(0xFF9B8CFF),
            artwork: _PeopleMiniArtwork(),
            onTap: () => context.go('/discovery'),
            onClose: () => _dismiss('people'),
          ),
        ),
      );
    }

    final List<Widget> spacedCards = <Widget>[];
    for (int index = 0; index < cards.length; index++) {
      if (index > 0) {
        spacedCards.add(SizedBox(width: index == 1 ? 14 : 12));
      }
      spacedCards.add(cards[index]);
    }
    return spacedCards;
  }

  void _dismiss(String id) => setState(() => _dismissedCards.add(id));
}

class _GalaxyHeader extends ConsumerWidget {
  const _GalaxyHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Profile? profile = ref.watch(currentProfileProvider).valueOrNull;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 760;
          final bool narrow = constraints.maxWidth < 430;
          final TextStyle wordmarkStyle = AppTextStyles.title().copyWith(
            fontSize: narrow ? 18 : 25,
            fontWeight: FontWeight.w800,
          );
          return Row(
            children: <Widget>[
              Container(
                width: narrow ? 32 : 44,
                height: narrow ? 32 : 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color(0xFF26D8FF),
                      Color(0xFF4338FF),
                      Color(0xFF090E35),
                    ],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.65),
                      blurRadius: 22,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF70DFFF),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.public_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              SizedBox(width: narrow ? 7 : 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Text(
                        'DreamWorld',
                        style: wordmarkStyle.copyWith(
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.1
                            ..color = const Color(0xFF78E9FF),
                          shadows: const <Shadow>[
                            Shadow(color: Color(0xFF20CFFF), blurRadius: 8),
                            Shadow(color: Color(0xFF765BFF), blurRadius: 18),
                          ],
                        ),
                      ),
                      NeonGradientText(
                        'DreamWorld',
                        gradient: const LinearGradient(
                          colors: <Color>[
                            Color(0xFFFFFFFF),
                            Color(0xFFD8F7FF),
                            Color(0xFF93DFFF),
                          ],
                        ),
                        style: wordmarkStyle,
                        glowColor: const Color(0xFF35C9FF),
                        glowRadius: 13,
                      ),
                    ],
                  ),
                  if (!narrow)
                    Text(
                      'Галактика возможностей',
                      style: AppTextStyles.caption(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (!compact)
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 410),
                    child: InkWell(
                      borderRadius: AppRadius.pillAll,
                      onTap: () => context.go('/discovery'),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xCC08142F),
                          borderRadius: AppRadius.pillAll,
                          border: Border.all(
                            color: const Color(0xFF2466A8)
                                .withValues(alpha: 0.75),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xFF168CFF)
                                  .withValues(alpha: 0.12),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF9BDFFF),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Поиск планет, людей, интересов...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (compact && !narrow) ...<Widget>[
                const Spacer(),
                _HeaderAction(
                  tooltip: 'Поиск',
                  icon: Icons.search_rounded,
                  onPressed: () => context.go('/discovery'),
                ),
              ] else
                const Spacer(),
              _HeaderAction(
                tooltip: 'Уведомления',
                icon: Icons.notifications_none_rounded,
                size: narrow ? 34 : 42,
                onPressed: () => context.go('/notifications'),
              ),
              _HeaderAction(
                tooltip: 'Настройки',
                icon: Icons.settings_outlined,
                size: narrow ? 34 : 42,
                onPressed: () => context.go('/settings'),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  AnimatedPress(
                    onPressed: () => context.go('/profile'),
                    scaleDown: 0.9,
                    child: AuraAvatar(
                      photoUrl: profile?.photoUrl,
                      size: narrow ? 32 : 40,
                      fallbackText: profile?.name,
                      fallbackIcon: Icons.person_rounded,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF35E58A),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF050B20),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.size = 42,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size <= 36 ? 1 : 3),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xB9081A38),
          foregroundColor: const Color(0xFFD9F3FF),
          side: BorderSide(
            color: const Color(0xFF3989C8).withValues(alpha: 0.48),
          ),
          fixedSize: Size(size, size),
        ),
        icon: Icon(icon, size: size <= 36 ? 19 : 22),
      ),
    );
  }
}

class _GalaxyInfoCard extends StatelessWidget {
  const _GalaxyInfoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onClose,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _RoundIcon(
                    icon: icon,
                    color: const Color(0xFF43BFFF),
                    size: 34,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label(color: AppColors.white)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _CloseCardButton(title: title, onPressed: onClose),
                ],
              ),
              const SizedBox(height: 7),
              Expanded(
                child: Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(color: AppColors.textSecondary)
                      .copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GalaxyActionCard extends StatelessWidget {
  const _GalaxyActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.artwork,
    required this.onTap,
    required this.onClose,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Widget artwork;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: _GlassPanel(
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _RoundIcon(icon: icon, color: accent, size: 34),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label(color: AppColors.white)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _CloseCardButton(title: title, onPressed: onClose),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(color: AppColors.textSecondary)
                        .copyWith(fontSize: 10),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 30,
                    child: Row(
                      children: <Widget>[
                        Expanded(child: artwork),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFFB8DFFF),
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseCardButton extends StatelessWidget {
  const _CloseCardButton({required this.title, required this.onPressed});

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: IconButton(
        tooltip: 'Закрыть: $title',
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 24, height: 24),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xCC0A1730),
          foregroundColor: const Color(0xFFD5E9FF),
          side: BorderSide(
            color: const Color(0xFF7BB8E8).withValues(alpha: 0.5),
          ),
        ),
        icon: const Icon(Icons.close_rounded, size: 14),
      ),
    );
  }
}

class _PlanetMiniArtwork extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<Color> colors = <Color>[
      Color(0xFF39B9FF),
      Color(0xFF9B70FF),
      Color(0xFFFFA83D),
      Color(0xFF38D9C1),
      Color(0xFFE35BBD),
    ];
    return Row(
      children: <Widget>[
        for (final Color color in colors)
          Align(
            widthFactor: 0.82,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.4),
                  colors: <Color>[
                    Colors.white,
                    color,
                    color.withValues(alpha: 0.35),
                  ],
                  stops: const <double>[0, 0.24, 1],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: 9,
                  ),
                ],
                border: Border.all(color: Colors.white54, width: 0.7),
              ),
            ),
          ),
      ],
    );
  }
}

class _PeopleMiniArtwork extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<Color> colors = <Color>[
      Color(0xFFFFC18C),
      Color(0xFFB8D7FF),
      Color(0xFFE8A8D9),
      Color(0xFF9BE2C5),
    ];
    return Row(
      children: <Widget>[
        for (final Color color in colors)
          Align(
            widthFactor: 0.82,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: color,
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF18304E),
                size: 17,
              ),
            ),
          ),
      ],
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xD9081633),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2877C2).withValues(alpha: 0.62),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF087DFF).withValues(alpha: 0.13),
            blurRadius: 22,
          ),
          const BoxShadow(
            color: Color(0x88000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.color, this.size = 40});
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color.withValues(alpha: 0.65)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }
}
