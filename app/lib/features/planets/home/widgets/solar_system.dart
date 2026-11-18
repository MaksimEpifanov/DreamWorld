import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../../data/models/planet.dart';
import '../../cosmos/realistic_planet.dart';
import '../../cosmos/realistic_sun.dart';

/// Солнечная система главной: солнце в центре и планеты по орбите.
///
/// Планеты расставляются равномерно по кругу, масштабируясь под доступное
/// пространство. Каждая планета — живой [PlanetOrb] с подписью и переходом
/// во «внутренний мир».
class SolarSystem extends StatelessWidget {
  const SolarSystem({
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
        final double height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : constraints.maxWidth;
        final double side = math.min(constraints.maxWidth, height);

        final double sunSize = side * 0.22;
        final double orbit = side * 0.30;
        final double orbSize = side * 0.105;
        final double labelWidth = side * 0.34;

        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                SizedBox(
                  width: orbit * 2,
                  height: orbit * 2,
                  child: CustomPaint(
                    painter: _OrbitPainter(color: scheme.primary),
                  ),
                ),
                _Sun(size: sunSize, color: scheme.primary),
                for (int i = 0; i < planets.length; i++)
                  _orbitPlanet(
                    planets[i],
                    i,
                    planets.length,
                    orbit,
                    orbSize,
                    labelWidth,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _orbitPlanet(
    Planet planet,
    int index,
    int count,
    double orbit,
    double orbSize,
    double labelWidth,
  ) {
    final double angle = -math.pi / 2 + (2 * math.pi / count) * index;
    final Offset offset = Offset(
      math.cos(angle) * orbit,
      math.sin(angle) * orbit,
    );

    return Transform.translate(
      offset: offset,
      child: _OrbitPlanet(
        planet: planet,
        size: orbSize,
        maxLabelWidth: labelWidth,
        onTap: () => onPlanetTap(planet),
      ),
    );
  }
}

/// Планета на орбите: живой вращающийся шар и подпись.
class _OrbitPlanet extends StatefulWidget {
  const _OrbitPlanet({
    required this.planet,
    required this.size,
    required this.maxLabelWidth,
    required this.onTap,
  });

  final Planet planet;
  final double size;
  final double maxLabelWidth;
  final VoidCallback onTap;

  @override
  State<_OrbitPlanet> createState() => _OrbitPlanetState();
}

class _OrbitPlanetState extends State<_OrbitPlanet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // У каждой планеты своя скорость вращения и фаза — движение живое.
    final double speed = 0.9 + (widget.planet.id.hashCode % 5) * 0.14;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (12000 / speed).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double phase = (widget.planet.id.hashCode % 100) / 100.0;

    return AnimatedPress(
      onPressed: widget.onTap,
      scaleDown: 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              final double turns = (phase + _controller.value) % 1.0;
              return RealisticPlanet(
                planet: widget.planet,
                size: widget.size,
                rotationTurns: turns,
              );
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            constraints: BoxConstraints(maxWidth: widget.maxLabelWidth),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.55),
              borderRadius: AppRadius.pillAll,
              border: Border.all(
                color: widget.planet.accent.withValues(alpha: 0.45),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: widget.planet.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              widget.planet.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Солнце по центру системы.
class _Sun extends StatelessWidget {
  const _Sun({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RealisticSun(size: size, glow: 0.5),
    );
  }
}

/// Тонкие орбитальные окружности вокруг солнца.
class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.1),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.color != color;
}
