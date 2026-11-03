import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/index.dart';
import '../../../../data/models/planet.dart';
import '../../cosmos/realistic_planet.dart';
import '../../cosmos/realistic_sun.dart';

/// Галактическая солнечная система главного экрана в стиле референса.
class GalacticHomeSystem extends StatelessWidget {
  const GalacticHomeSystem({
    super.key,
    required this.planets,
    required this.onPlanetTap,
  });

  final List<Planet> planets;
  final ValueChanged<Planet> onPlanetTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double h = constraints.maxHeight.isFinite ? constraints.maxHeight : constraints.maxWidth;
        final double w = constraints.maxWidth;
        final double side = math.min(w, h);
        final double effectiveSide = side * 0.72;
        final double scale = effectiveSide / 820.0;

        final double sunSize = (144.0 * scale).clamp(94.0, 150.0);
        final double orbit1 = (255.0 * scale).clamp(172.0, 282.0);
        final double orbit2 = (335.0 * scale).clamp(232.0, 368.0);
        final double orbit3 = (415.0 * scale).clamp(290.0, 464.0);
        final double planetSize = (72.0 * scale).clamp(54.0, 82.0);

        final List<Planet> displayPlanets = List<Planet>.from(planets);
        displayPlanets.removeWhere((Planet p) =>
            p.id == 'p_gardening' || p.name.toLowerCase().contains('садов'));
        final int financeIdx = displayPlanets.indexWhere((Planet p) =>
            p.id == 'p_finance' || p.name.toLowerCase().contains('финанс'));
        if (financeIdx >= 0) {
          final Planet financePlanet = displayPlanets.removeAt(financeIdx);
          final int techIdx = displayPlanets.indexWhere((Planet p) =>
              p.id == 'p_tech' || p.name.toLowerCase().contains('технолог'));
          final int foodIdx = displayPlanets.indexWhere((Planet p) =>
              p.id == 'p_food' || p.name.toLowerCase().contains('кулинар'));
          int insertAt = -1;
          if (foodIdx >= 0 && techIdx >= 0) {
            insertAt = foodIdx < techIdx ? foodIdx + 1 : techIdx + 1;
          } else if (foodIdx >= 0) {
            insertAt = foodIdx + 1;
          } else if (techIdx >= 0) {
            insertAt = techIdx;
          }
          if (insertAt < 0) {
            insertAt = 6;
          }
          if (insertAt > displayPlanets.length) {
            insertAt = displayPlanets.length;
          }
          displayPlanets.insert(insertAt, financePlanet);
        }
        final int esotericIdx = displayPlanets.indexWhere((Planet p) =>
            p.id == 'p_esoteric' || p.name.toLowerCase().contains('изотер'));
        if (esotericIdx >= 0) {
          final Planet esotericPlanet = displayPlanets.removeAt(esotericIdx);
          final int financeIdx2 = displayPlanets.indexWhere((Planet p) =>
              p.id == 'p_finance' || p.name.toLowerCase().contains('финанс'));
          final int techIdx2 = displayPlanets.indexWhere((Planet p) =>
              p.id == 'p_tech' || p.name.toLowerCase().contains('технолог'));
          int insertAt = -1;
          if (financeIdx2 >= 0 && techIdx2 >= 0) {
            insertAt = financeIdx2 < techIdx2 ? financeIdx2 + 1 : techIdx2;
          } else if (financeIdx2 >= 0) {
            insertAt = financeIdx2 + 1;
          } else if (techIdx2 >= 0) {
            insertAt = techIdx2;
          }
          if (insertAt < 0) {
            insertAt = 7;
          }
          if (insertAt > displayPlanets.length) {
            insertAt = displayPlanets.length;
          }
          displayPlanets.insert(insertAt, esotericPlanet);
        }

        final List<_Orbit> orbits = <_Orbit>[
          _Orbit(radius: orbit1, count: 6, startIndex: 0),
          _Orbit(radius: orbit2, count: 6, startIndex: 6),
          _Orbit(radius: orbit3, count: math.max(0, displayPlanets.length - 12), startIndex: 12),
        ];

        final List<Widget> children = <Widget>[
          _OrbitRing(radius: orbit1, color: scheme.primary),
          _OrbitRing(radius: orbit2, color: scheme.primary),
          _OrbitRing(radius: orbit3, color: scheme.primary),
          Center(
            child: _CentralSun(size: sunSize),
          ),
        ];

        int planetIndex = 0;
        for (int o = 0; o < orbits.length; o++) {
          final _Orbit orbit = orbits[o];
          for (int i = 0; i < orbit.count && planetIndex < displayPlanets.length; i++, planetIndex++) {
            final Planet planet = displayPlanets[planetIndex];
            double angle = -math.pi / 2 + (2 * math.pi / orbit.count) * i + o * 0.28;
            final String name = planet.name.toLowerCase();
            if (name.contains('изотер')) {
              angle += 0.18;
            }
            if (name.contains('технолог')) {
              angle -= 0.1;
            }
            if (name.contains('финанс')) {
              angle -= 0.08;
            }
            if (name.contains('добра')) {
              angle += 0.06;
            }
            if (name.contains('коллекц')) {
              angle += 0.08;
            }
            final double x = math.cos(angle) * orbit.radius;
            final double y = math.sin(angle) * orbit.radius;

            children.add(
              Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: Offset(x, y),
                  child: _GalaxyPlanet(
                    planet: planet,
                    size: planetSize,
                    onTap: () => onPlanetTap(planet),
                  ),
                ),
              ),
            );
          }
        }

        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(200),
          minScale: 0.4,
          maxScale: 1.6,
          constrained: false,
          child: SizedBox(
            width: effectiveSide * 1.6,
            height: effectiveSide * 1.6,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: children,
            ),
          ),
        );
      },
    );
  }
}

class _Orbit {
  const _Orbit({required this.radius, required this.count, required this.startIndex});
  final double radius;
  final int count;
  final int startIndex;
}

class _OrbitRing extends StatelessWidget {
  const _OrbitRing({required this.radius, required this.color});
  final double radius;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.16), width: 1),
          boxShadow: <BoxShadow>[
            BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 24),
          ],
        ),
      ),
    );
  }
}

class _CentralSun extends StatelessWidget {
  const _CentralSun({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: size * 1.6,
            height: size * 1.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  const Color(0xFFF59E0B).withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          RealisticSun(size: size, glow: 0.7),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('ДОБРО ПОЖАЛОВАТЬ', style: AppTextStyles.caption(color: AppColors.white.withValues(alpha: 0.9))),
              Text('В ГАЛАКТИКУ', style: AppTextStyles.caption(color: AppColors.white.withValues(alpha: 0.9))),
              const SizedBox(height: 4),
              Text(
                'DreemWorld',
                style: AppTextStyles.title().copyWith(
                  fontSize: 22,
                  letterSpacing: 1.2,
                  shadows: <Shadow>[
                    Shadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.8), blurRadius: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      )
          .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
          .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 2800.ms),
    );
  }
}

class _GalaxyPlanet extends StatefulWidget {
  const _GalaxyPlanet({required this.planet, required this.size, required this.onTap});
  final Planet planet;
  final double size;
  final VoidCallback onTap;

  @override
  State<_GalaxyPlanet> createState() => _GalaxyPlanetState();
}

class _GalaxyPlanetState extends State<_GalaxyPlanet> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final double speed = 0.8 + (widget.planet.id.hashCode % 4) * 0.12;
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: (14000 / speed).round()))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double phase = (widget.planet.id.hashCode % 100) / 100.0;
    final Color accent = widget.planet.accent;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: widget.size + 18,
                height: widget.size + 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[accent.withValues(alpha: 0.16), Colors.transparent],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  final double turns = (phase + _controller.value) % 1.0;
                  return RealisticPlanet(
                    planet: widget.planet,
                    size: widget.size,
                    rotationTurns: turns,
                    glow: 0.45,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Column(
            children: <Widget>[
              Text(
                widget.planet.name.replaceFirst('Планета ', ''),
                style: AppTextStyles.caption(color: AppColors.white),
              ),
              Text(
                _countForPlanet(widget.planet.id),
                style: AppTextStyles.caption(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _countForPlanet(String id) {
    final int h = id.hashCode.abs();
    final int count = 5000 + (h % 25000);
    return '$count человек';
  }
}
