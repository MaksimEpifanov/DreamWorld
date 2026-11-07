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
    final List<Planet> featured = ref.watch(featuredPlanetsProvider);
    final ColorScheme scheme = Theme.of(context).colorScheme;

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
                    Positioned(
                      left: wide ? 18 : 10,
                      right: wide ? 18 : 10,
                      bottom: 12,
                      child: _HomeHighlights(planets: featured, wide: wide),
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

class _HomeHighlights extends StatelessWidget {
  const _HomeHighlights({required this.planets, required this.wide});
  final List<Planet> planets;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return SizedBox(
        height: 74,
        child: _GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: <Widget>[
              const _RoundIcon(icon: Icons.auto_awesome_rounded, color: Color(0xFF8A7BFF)),
              const SizedBox(width: 10),
              Expanded(
                child: Text('22 планеты — тысячи историй',
                    style: AppTextStyles.label(color: Colors.white)),
              ),
              IconButton(
                onPressed: () => context.go('/main/planets'),
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: 230,
          child: _GlassPanel(
            child: const Row(
              children: <Widget>[
                _RoundIcon(icon: Icons.auto_awesome_rounded, color: Color(0xFF8A7BFF)),
                SizedBox(width: 10),
                Expanded(
                  child: Text('22 планеты — тысячи историй\nВыбирай то, что вдохновляет. На каждой планете — люди, события и новые возможности.',
                      style: TextStyle(color: Colors.white, fontSize: 12, height: 1.35)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HighlightCard(
            icon: Icons.groups_rounded,
            title: 'Популярные планеты',
            subtitle: 'Сейчас на пике интереса',
            planets: planets.take(4).toList(),
            onTap: () => context.go('/main/planets'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HighlightCard(
            icon: Icons.event_rounded,
            title: 'Ближайшие события',
            subtitle: 'Не пропусти самое интересное',
            planets: const <Planet>[],
            onTap: () => context.go('/main/planet/p_travel/news'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HighlightCard(
            icon: Icons.star_rounded,
            title: 'Новые люди',
            subtitle: 'Кто-то уже ждёт тебя',
            planets: const <Planet>[],
            onTap: () => context.go('/discovery'),
          ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.planets,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Planet> planets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Row(
          children: <Widget>[
            _RoundIcon(icon: icon, color: const Color(0xFF8D7BFF), size: 34),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(title, style: AppTextStyles.label(color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTextStyles.caption(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  if (planets.isNotEmpty)
                    Wrap(
                      spacing: 5,
                      children: planets.map((Planet p) => Container(
                        width: 23,
                        height: 23,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: <Color>[p.primary, p.accent]),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
                        ),
                        child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 12))),
                      )).toList(),
                    )
                  else
                    const Text('Открой новые возможности', style: TextStyle(color: Color(0xFFB7C9E8), fontSize: 10)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Color(0xFF9DDCFF)),
          ],
        ),
      ),
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
