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
        final double centerX = width / 2;
        final double centerY = height * 0.49;
        final double sunSize = (shortSide * 0.19).clamp(112.0, 190.0);
        final List<double> radii = <double>[
          shortSide * 0.275,
          shortSide * 0.385,
          shortSide * 0.49,
        ];
        final List<int> perOrbit = <int>[6, 8, 8];
        final double planetSize = (shortSide * 0.068).clamp(46.0, 70.0);
        final List<Planet> visible = planets.take(22).toList();

        final List<Widget> layers = <Widget>[
          const Positioned.fill(child: CustomPaint(painter: _GalaxyDustPainter())),
          for (int i = 0; i < radii.length; i++)
            Positioned(
              left: centerX - radii[i] * 1.12,
              top: centerY - radii[i] * 0.66,
              width: radii[i] * 2.24,
              height: radii[i] * 1.32,
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
            final double phase = orbit == 0 ? 0 : (orbit == 1 ? 0.19 : -0.12);
            final double angle = -math.pi / 2 +
                (2 * math.pi * i / perOrbit[orbit]) + phase;
            final double x = centerX + math.cos(angle) * radii[orbit] * 1.02;
            final double y = centerY + math.sin(angle) * radii[orbit] * 0.66;
            final double size = planetSize *
                (orbit == 2 ? 0.88 : (orbit == 0 ? 1.08 : 1));
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
          child: Stack(clipBehavior: Clip.none, children: layers),
        );
      },
    );
  }
}

/// Многослойная иллюстрация галактики: туманности, спиральные рукава,
/// звёздное поле и мягко подсвеченные орбитальные дуги.
class _GalaxyDustPainter extends CustomPainter {
  const _GalaxyDustPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF02091E),
            Color(0xFF07143A),
            Color(0xFF03091F),
            Color(0xFF010617),
          ],
          stops: <double>[0, 0.34, 0.72, 1],
        ).createShader(bounds),
    );

    final Offset center = Offset(size.width * 0.5, size.height * 0.49);
    final double scale = size.shortestSide;

    _glow(canvas, center + Offset(-scale * 0.19, -scale * 0.18),
        scale * 0.48, const Color(0xFF243BFF), 0.23);
    _glow(canvas, center + Offset(scale * 0.23, scale * 0.11),
        scale * 0.43, const Color(0xFF8B20FF), 0.19);
    _glow(canvas, center + Offset(-scale * 0.02, scale * 0.28),
        scale * 0.35, const Color(0xFF087DFF), 0.16);
    _glow(canvas, center + Offset(-scale * 0.32, scale * 0.12),
        scale * 0.25, const Color(0xFFB51DFF), 0.13);

    _drawSpiralArm(canvas, center, scale, -0.58, const Color(0xFF8D42FF), 0.18);
    _drawSpiralArm(canvas, center, scale, 2.42, const Color(0xFF168EFF), 0.17);
    _drawSpiralArm(canvas, center, scale, 0.92, const Color(0xFF452CBA), 0.12);

    for (int ring = 0; ring < 5; ring++) {
      final double rx = scale * (0.16 + ring * 0.085);
      final double ry = rx * 0.62;
      final Rect oval = Rect.fromCenter(
        center: center,
        width: rx * 2,
        height: ry * 2,
      );
      canvas.drawOval(
        oval,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ring == 2 ? 1.35 : 0.8
          ..color = (ring.isEven
                  ? const Color(0xFF6B70FF)
                  : const Color(0xFF28A7FF))
              .withValues(alpha: 0.10 + ring * 0.012)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }

    final math.Random random = math.Random(83);
    for (int i = 0; i < 520; i++) {
      final Offset point = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final double radius = random.nextDouble() * 1.35 + 0.2;
      final double alpha = 0.16 + random.nextDouble() * 0.58;
      final Color color = i % 11 == 0
          ? const Color(0xFFFFC77A)
          : (i % 5 == 0
              ? const Color(0xFFB78CFF)
              : const Color(0xFFB9D7FF));
      canvas.drawCircle(
        point,
        radius,
        Paint()..color = color.withValues(alpha: alpha),
      );
      if (i % 47 == 0) {
        _drawStar(canvas, point, radius * 3.5, color);
      }
    }

    _glow(canvas, center, scale * 0.16, const Color(0xFFFF8A24), 0.12);
  }

  void _glow(Canvas canvas, Offset center, double radius, Color color,
      double opacity) {
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.42),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.48, 1],
        ).createShader(rect),
    );
  }

  void _drawSpiralArm(Canvas canvas, Offset center, double scale,
      double rotation, Color color, double opacity) {
    final Path path = Path();
    for (int i = 0; i <= 90; i++) {
      final double t = i / 90;
      final double angle = rotation + t * math.pi * 1.48;
      final double radius = scale * (0.10 + t * 0.43);
      final Offset point = center +
          Offset(math.cos(angle) * radius * 1.55,
              math.sin(angle) * radius * 0.76);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = scale * 0.055
        ..color = color.withValues(alpha: opacity * 0.24)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.035),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.2
        ..color = color.withValues(alpha: opacity),
    );
  }

  void _drawStar(Canvas canvas, Offset point, double radius, Color color) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.82)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(point + Offset(-radius * 2, 0),
        point + Offset(radius * 2, 0), paint);
    canvas.drawLine(point + Offset(0, -radius * 2),
        point + Offset(0, radius * 2), paint);
    canvas.drawCircle(
      point,
      radius * 0.55,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _GalaxyDustPainter oldDelegate) => false;
}

class _OrbitRing extends StatelessWidget {
  const _OrbitRing({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final Color tint =
        index == 1 ? const Color(0xFF8D6BFF) : const Color(0xFF54A9FF);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.elliptical(999, 999)),
        border: Border.all(
          color: tint.withValues(alpha: 0.22 - index * 0.035),
          width: 1,
        ),
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
                colors: <Color>[
                  Color(0x99FF9C24),
                  Color(0x44FF6A00),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          RealisticSun(size: size, glow: 0.9),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('ДОБРО ПОЖАЛОВАТЬ',
                  style: AppTextStyles.caption(color: Colors.white)),
              Text('В ГАЛАКТИКУ',
                  style: AppTextStyles.caption(color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                'DreamWorld',
                style: AppTextStyles.title().copyWith(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  shadows: const <Shadow>[
                    Shadow(color: Color(0xFFFF9D22), blurRadius: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(0.985, 0.985),
            end: const Offset(1.015, 1.015),
            duration: 3200.ms,
          ),
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
                        colors: <Color>[
                          planet.accent.withValues(alpha: 0.32),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: RealisticPlanet(
                      planet: planet,
                      size: size,
                      glow: 0.72,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      width: size * 0.54,
                      height: size * 0.54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(
                          planet.primary,
                          const Color(0xFF06152E),
                          0.28,
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.78),
                          width: 1.2,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: planet.accent.withValues(alpha: 0.65),
                            blurRadius: 17,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          planet.emoji,
                          style: TextStyle(fontSize: size * 0.27),
                        ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xE9071732),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF327DC1).withValues(alpha: 0.65),
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label(color: Colors.white)
                          .copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.people_alt_rounded,
                          size: 10,
                          color: Color(0xFFB9D9FF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          count,
                          style: AppTextStyles.caption(
                            color: const Color(0xFFB9D9FF),
                          ).copyWith(fontSize: 10),
                        ),
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
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} млн';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)} тыс.';
    }
    return value.toString();
  }
}
