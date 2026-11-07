import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/index.dart';
import '../../../../data/models/planet.dart';
import '../../cosmos/realistic_planet.dart';
import '../../cosmos/realistic_sun.dart';

/// Центральная интерактивная галактика главного экрана DreamWorld.
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double shortSide = math.min(width, height);
        final double unit = shortSide / 900;
        final double centerX = width / 2;
        final double centerY = height * 0.47;
        final double sunSize = (shortSide * 0.19).clamp(112.0, 190.0);
        final List<double> radii = <double>[
          shortSide * 0.235,
          shortSide * 0.345,
          shortSide * 0.445,
        ];
        final List<int> perOrbit = <int>[6, 8, 8];
        final double planetSize = (shortSide * 0.085).clamp(62.0, 92.0);
        final List<Planet> visible = planets.take(22).toList();

        final List<Widget> layers = <Widget>[
          Positioned.fill(child: CustomPaint(painter: _GalaxyDustPainter())),
          for (int i = 0; i < radii.length; i++)
            Positioned(
              left: centerX - radii[i] * 1.18,
              top: centerY - radii[i] * 0.78,
              width: radii[i] * 2.36,
              height: radii[i] * 1.56,
              child: _OrbitRing(index: i),
            ),
          Positioned(
            left: centerX - sunSize * 0.95,
            top: centerY - sunSize * 0.95,
            width: sunSize * 1.9,
            height: sunSize * 1.9,
            child: _CentralSun(size: sunSize),
          ),
        ];

        int planetIndex = 0;
        for (int orbit = 0; orbit < perOrbit.length; orbit++) {
          for (int i = 0; i < perOrbit[orbit] && planetIndex < visible.length; i++) {
            final Planet planet = visible[planetIndex++];
            final double angle = -math.pi / 2 +
                (2 * math.pi * i / perOrbit[orbit]) +
                (orbit.isOdd ? 0.18 : 0);
            final double x = centerX + math.cos(angle) * radii[orbit] * 1.12;
            final double y = centerY + math.sin(angle) * radii[orbit] * 0.72;
            final double size = planetSize * (orbit == 2 ? 0.9 : 1);
            layers.add(
              Positioned(
                left: x - size * 0.95,
                top: y - size * 0.95,
                width: size * 1.9,
                child: _GalaxyPlanet(
                  planet: planet,
                  size: size,
                  onTap: () => onPlanetTap(planet),
                ),
              ),
            );
          }
        }

        return ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: layers,
          ),
        );
      },
    );
  }
}

class _GalaxyDustPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final math.Random random = math.Random(83);
    for (int i = 0; i < 85; i++) {
      final Offset point = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final double radius = random.nextDouble() * 1.5 + 0.3;
      canvas.drawCircle(
        point,
        radius,
        Paint()..color = const Color(0xFFB9D7FF).withValues(alpha: random.nextDouble() * 0.55),
      );
    }
    final Offset center = Offset(size.width / 2, size.height * 0.47);
    for (int i = 0; i < 18; i++) {
      final double angle = i * math.pi / 9;
      final Offset p1 = center + Offset(math.cos(angle) * size.shortestSide * 0.12, math.sin(angle) * size.shortestSide * 0.12);
      final Offset p2 = center + Offset(math.cos(angle) * size.shortestSide * 0.49, math.sin(angle) * size.shortestSide * 0.49);
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = const Color(0xFF526BD8).withValues(alpha: 0.045)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxyDustPainter oldDelegate) => false;
}

class _OrbitRing extends StatelessWidget {
  const _OrbitRing({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final Color tint = index == 1 ? const Color(0xFF8D6BFF) : const Color(0xFF54A9FF);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.elliptical(999, 999)),
        border: Border.all(color: tint.withValues(alpha: 0.22 - index * 0.035), width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(color: tint.withValues(alpha: 0.06), blurRadius: 20),
        ],
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
            width: size * 1.9,
            height: size * 1.9,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[Color(0x88FF9C24), Color(0x33FF6A00), Colors.transparent],
              ),
            ),
          ),
          RealisticSun(size: size, glow: 0.9),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('ДОБРО ПОЖАЛОВАТЬ', style: AppTextStyles.caption(color: Colors.white)),
              Text('В ГАЛАКТИКУ', style: AppTextStyles.caption(color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                'DreamWorld',
                style: AppTextStyles.title().copyWith(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  shadows: const <Shadow>[Shadow(color: Color(0xFFFF9D22), blurRadius: 18)],
                ),
              ),
            ],
          ),
        ],
      ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
        .scale(begin: const Offset(0.985, 0.985), end: const Offset(1.015, 1.015), duration: 3200.ms),
    );
  }
}

class _GalaxyPlanet extends StatelessWidget {
  const _GalaxyPlanet({
    required this.planet,
    required this.size,
    required this.onTap,
  });

  final Planet planet;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String title = planet.name.replaceFirst('Планета ', '');
    final String count = _formatCount(planet.memberCount);
    return Semantics(
      button: true,
      label: '$title, $count участников',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: size * 1.55,
              height: size * 1.13,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: size * 1.48,
                    height: size * 1.48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[planet.accent.withValues(alpha: 0.32), Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: RealisticPlanet(planet: planet, size: size, glow: 0.72),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      width: size * 0.54,
                      height: size * 0.54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(planet.primary, const Color(0xFF06152E), 0.28),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.78), width: 1.2),
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: planet.accent.withValues(alpha: 0.65), blurRadius: 17),
                        ],
                      ),
                      child: Center(
                        child: Text(planet.emoji, style: TextStyle(fontSize: size * 0.27)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -size * 0.02),
              child: Container(
                constraints: BoxConstraints(maxWidth: size * 1.85),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xE9071732),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF327DC1).withValues(alpha: 0.65)),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 5)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label(color: Colors.white).copyWith(fontSize: 11)),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.people_alt_rounded, size: 10, color: Color(0xFFB9D9FF)),
                        const SizedBox(width: 4),
                        Text(count, style: AppTextStyles.caption(color: const Color(0xFFB9D9FF)).copyWith(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)} млн';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)} тыс.';
    return value.toString();
  }
}
