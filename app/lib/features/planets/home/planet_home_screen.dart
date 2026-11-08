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
class PlanetHomeScreen extends ConsumerWidget {
  const PlanetHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Planet> planets = ref.watch(planetsProvider);
    return SafeArea(
      child: Column(
        children: <Widget>[
          const _GalaxyHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 900;
                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned.fill(
                      child: GalacticHomeSystem(
                        planets: planets,
                        onPlanetTap: (Planet planet) =>
                            context.go('/main/planet/${planet.id}'),
                      ),
                    ),
                    if (wide)
                      Positioned(
                        left: 18,
                        top: 18,
                        width: 238,
                        child: _GlassPanel(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Найди своих по интересам',
                                        style: AppTextStyles.label(color: AppColors.white)),
                                    const SizedBox(height: 5),
                                    Text('Люди, близкие тебе по увлечениям и взглядам',
                                        style: AppTextStyles.caption(color: AppColors.textSecondary)),
                                    const SizedBox(height: 10),
                                    NeonButton(
                                      label: 'Перейти',
                                      onPressed: () => context.go('/discovery'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (wide && constraints.maxHeight >= 620)
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 14,
                        height: 112,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(
                              width: 218,
                              child: _GalaxyInfoCard(
                                icon: Icons.auto_awesome_rounded,
                                title: '22 планеты — тысячи историй',
                                description:
                                    'Выбирай то, что вдохновляет. На каждой планете — люди, события и новые возможности.',
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _GalaxyActionCard(
                                icon: Icons.groups_rounded,
                                title: 'Популярные планеты',
                                subtitle: 'Сейчас на пике интереса',
                                accent: const Color(0xFF9B8CFF),
                                artwork: _PlanetMiniArtwork(),
                                onTap: () => context.go('/main/planets'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GalaxyActionCard(
                                icon: Icons.calendar_month_rounded,
                                title: 'Ближайшие события',
                                subtitle: 'Не пропусти самое интересное',
                                accent: const Color(0xFF55C8FF),
                                artwork: _LandscapeMiniArtwork(),
                                onTap: () => context.go('/discovery'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GalaxyActionCard(
                                icon: Icons.star_rounded,
                                title: 'Новые люди',
                                subtitle: 'Кто-то уже ждёт тебя',
                                accent: const Color(0xFF9B8CFF),
                                artwork: _PeopleMiniArtwork(),
                                onTap: () => context.go('/discovery'),
                              ),
                            ),
                          ],
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
          return Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF26D8FF), Color(0xFF4338FF), Color(0xFF090E35)],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: scheme.primary.withValues(alpha: 0.65), blurRadius: 22),
                  ],
                  border: Border.all(color: const Color(0xFF70DFFF), width: 1.2),
                ),
                child: const Icon(Icons.public_rounded, color: Colors.white, size: 27),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  NeonGradientText(
                    'DreamWorld',
                    gradient: const LinearGradient(colors: <Color>[Color(0xFFE8F8FF), Color(0xFF69C9FF)]),
                    style: AppTextStyles.title().copyWith(fontSize: 25, fontWeight: FontWeight.w800),
                    glowColor: const Color(0xFF168CFF),
                  ),
                  Text('Галактика возможностей',
                      style: AppTextStyles.caption(color: AppColors.textSecondary)),
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
                          border: Border.all(color: const Color(0xFF2466A8).withValues(alpha: 0.75)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: const Color(0xFF168CFF).withValues(alpha: 0.12), blurRadius: 18),
                          ],
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.search_rounded, color: Color(0xFF9BDFFF)),
                            const SizedBox(width: 10),
                            Text('Поиск планет, людей, интересов...',
                                style: AppTextStyles.body(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              IconButton(
                tooltip: 'Уведомления',
                onPressed: () => context.go('/chats'),
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 27),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  AnimatedPress(
                    onPressed: () => context.go('/profile'),
                    scaleDown: 0.9,
                    child: AuraAvatar(
                      photoUrl: profile?.photoUrl,
                      size: 40,
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
                        border: Border.all(color: const Color(0xFF050B20), width: 1.5),
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


class _GalaxyInfoCard extends StatelessWidget {
  const _GalaxyInfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const _RoundIcon(
                icon: Icons.auto_awesome_rounded,
                color: Color(0xFF43BFFF),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Widget artwork;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: _GlassPanel(
          child: Column(
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
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFB8DFFF),
                    size: 17,
                  ),
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
              SizedBox(height: 30, child: artwork),
            ],
          ),
        ),
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
                  colors: <Color>[Colors.white, color, color.withValues(alpha: 0.35)],
                  stops: const <double>[0, 0.24, 1],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 9),
                ],
                border: Border.all(color: Colors.white54, width: 0.7),
              ),
            ),
          ),
      ],
    );
  }
}

class _LandscapeMiniArtwork extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF79C8F4),
              Color(0xFF456D8F),
              Color(0xFF1A4560),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 12,
              bottom: -14,
              child: Icon(Icons.landscape_rounded,
                  size: 76, color: Colors.white.withValues(alpha: 0.72)),
            ),
            Positioned(
              right: 18,
              bottom: -8,
              child: Icon(Icons.terrain_rounded,
                  size: 60, color: const Color(0xFF173F57).withValues(alpha: 0.9)),
            ),
          ],
        ),
      ),
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
              child: const Icon(Icons.person_rounded,
                  color: Color(0xFF18304E), size: 17),
            ),
          ),
      ],
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.padding = const EdgeInsets.all(12)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xD9081633),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2877C2).withValues(alpha: 0.62)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: const Color(0xFF087DFF).withValues(alpha: 0.13), blurRadius: 22),
          const BoxShadow(color: Color(0x88000000), blurRadius: 16, offset: Offset(0, 7)),
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
        boxShadow: <BoxShadow>[BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16)],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }
}
