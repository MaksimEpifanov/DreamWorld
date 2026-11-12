import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/index.dart';
import '../../../../data/models/planet.dart';
import '../../cosmos/realistic_planet.dart';
import '../../cosmos/realistic_sun.dart';

/// Центральная интерактивная галактика главного экрана DreamWorld.
class GalacticHomeSystem extends StatefulWidget {
  const GalacticHomeSystem({
    super.key,
    required this.planets,
    required this.onPlanetTap,
    this.bottomReservedSpace = 0,
  });

  final List<Planet> planets;
  final ValueChanged<Planet> onPlanetTap;
  final double bottomReservedSpace;

  @override
  State<GalacticHomeSystem> createState() => _GalacticHomeSystemState();
}

class _GalacticHomeSystemState extends State<GalacticHomeSystem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double shortSide = math.min(width, height);
        final double centerX = width / 2;
        final double availableHeight = (height - widget.bottomReservedSpace)
            .clamp(1.0, height);
        final double centerY = availableHeight * 0.5;
        final double orbitalScale = math.min(width, availableHeight);
        final bool compactLayout = width < 1200;
        final double sunSize = (shortSide * 0.19).clamp(112.0, 190.0);
        final double basePlanetSize = (math.min(
          width * 0.075,
          height * 0.115,
        )).clamp(48.0, 78.0);
        final double planetSize =
            basePlanetSize *
            (width < 700
                ? 0.55
                : compactLayout
                ? 0.65
                : 1);
        final List<Planet> visible = widget.planets.take(21).toList();
        final double maxNodeHeight =
            planetSize * (width < 1200 ? 1.13 : 1.48) +
            (width < 700
                ? 38
                : compactLayout
                ? 34
                : 40);
        final double orbitWidth = _orbitWidth(width, orbitalScale);
        final double orbitHeight = _orbitHeight(
          availableHeight,
          orbitalScale,
          maxNodeHeight,
        );

        final Map<String, double> sizeFactors = <String, double>{
          'p_tech': 1.08,
          'p_travel': 1.04,
          'p_nature': 1.12,
          'p_music': 1.08,
          'p_cinema': 1.02,
          'p_fishing': 1.10,
          'p_reading': 0.92,
          'p_art': 1.03,
          'p_gaming': 1.12,
          'p_animals': 1.02,
          'p_gardening': 1.02,
          'p_volunteering': 1.06,
          'p_finance': 1.05,
          'p_esoteric': 0.98,
          'p_psychology': 1.05,
          'p_food': 1.08,
          'p_sports': 1.08,
        };

        final List<Widget> layers = <Widget>[
          const Positioned.fill(
            child: CustomPaint(painter: _GalaxyDustPainter()),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (BuildContext context, Widget? child) {
                  return CustomPaint(
                    painter: _TwinkleStarsPainter(
                      phase: _rotationController.value,
                    ),
                  );
                },
              ),
            ),
          ),
          for (int ring = 0; ring < 3; ring++)
            Positioned(
              left: centerX - orbitWidth * _orbitRadius(ring, compactLayout),
              top: centerY - orbitHeight * _orbitRadius(ring, compactLayout),
              width: orbitWidth * _orbitRadius(ring, compactLayout) * 2,
              height: orbitHeight * _orbitRadius(ring, compactLayout) * 2,
              child: _OrbitRing(index: ring),
            ),
          Positioned(
            left: centerX - sunSize * 0.95,
            top: centerY - sunSize * 0.95,
            width: sunSize * 1.25,
            height: sunSize * 1.25,
            child: _CentralSun(size: sunSize),
          ),
        ];

        final Rect sunExclusion = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: sunSize * 1.9,
          height: sunSize * 1.9,
        ).inflate(12);
        final List<Rect> occupied = <Rect>[
          sunExclusion,
          if (width >= 900) const Rect.fromLTWH(0, 0, 270, 185),
        ];
        final List<Planet> placementOrder = List<Planet>.of(visible)
          ..sort((Planet a, Planet b) {
            if (a.id == 'p_cars') return -1;
            if (b.id == 'p_cars') return 1;
            return 0;
          });
        for (final Planet planet in placementOrder) {
          final int index = visible.indexOf(planet);
          final double size = planetSize * (sizeFactors[planet.id] ?? 0.94);
          final int ring = index < 6 ? 0 : (index < 14 ? 1 : 2);
          final int firstIndex = ring == 0 ? 0 : (ring == 1 ? 6 : 14);
          final int count = ring == 0 ? 6 : (ring == 1 ? 8 : 8);
          final int positionInRing = index - firstIndex;
          final double orbitalAngle =
              -math.pi / 2 +
              positionInRing * 2 * math.pi / count +
              ring * math.pi / 9;
          final double angle = planet.id == 'p_cars' ? -0.18 : orbitalAngle;
          final double labelWidth = math.min(
            width * 0.28,
            width < 700
                ? 64
                : compactLayout
                ? 104
                : size * 2.0,
          );
          final double nodeWidth = math.max(size * 1.55, labelWidth);
          final double nodeHeight =
              size * (width < 1200 ? 1.13 : 1.48) +
              (width < 700
                  ? 38
                  : compactLayout
                  ? 34
                  : 40);
          final double motionX = width * 0.002;
          final double motionY = height * 0.003;
          final Offset? position = _findPlanetPosition(
            angle: angle,
            ring: ring,
            center: Offset(centerX, centerY),
            orbitWidth: orbitWidth,
            orbitHeight: orbitHeight,
            nodeWidth: nodeWidth,
            nodeHeight: nodeHeight,
            sceneWidth: width,
            sceneHeight: availableHeight,
            occupied: occupied,
            motionPadding: Offset(motionX, motionY),
            protectedBounds: sunExclusion,
            targetRadius: planet.id == 'p_cars' ? 0.42 : 0.9,
          );
          if (position == null) continue;
          final double x = position.dx;
          final double y = position.dy;
          occupied.add(
            Rect.fromCenter(
              center: position,
              width: nodeWidth,
              height: nodeHeight,
            ).inflate((width < 700 ? 2 : 3) + math.max(motionX, motionY)),
          );
          layers.add(
            Positioned(
              key: ValueKey<String>('galaxy-planet-${planet.id}'),
              left: x - nodeWidth / 2,
              top: y - nodeHeight / 2,
              width: nodeWidth,
              height: nodeHeight,
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (BuildContext context, Widget? child) {
                  final int speed = 1 + index % 3;
                  final double direction = index.isEven ? 1 : -1;
                  final double phase =
                      _rotationController.value *
                          2 *
                          math.pi *
                          (0.12 + (index % 4) * 0.025) +
                      index * 0.83;
                  final double atmospherePulse =
                      (math.sin(
                            _rotationController.value * 2 * math.pi * 2 + index,
                          ) +
                          1) *
                      0.5;
                  final double orbitX = math.cos(phase) * motionX;
                  final double orbitY = math.sin(phase) * motionY;
                  return Transform.translate(
                    offset: Offset(orbitX, orbitY),
                    child: _GalaxyPlanet(
                      planet: planet,
                      size: size,
                      maxLabelWidth: labelWidth,
                      compactLabel: compactLayout,
                      rotationTurns:
                          _rotationController.value * speed * direction,
                      atmospherePulse: atmospherePulse,
                      ringRotationTurns:
                          _rotationController.value *
                          (index.isEven ? 0.12 : -0.12),
                      onTap: () => widget.onPlanetTap(planet),
                    ),
                  );
                },
              ),
            ),
          );
        }

        return ClipRect(
          child: Stack(clipBehavior: Clip.none, children: layers),
        );
      },
    );
  }

  double _orbitRadius(int ring, bool compactLayout) {
    if (compactLayout) {
      switch (ring) {
        case 0:
          return 0.72;
        case 1:
          return 0.88;
        default:
          return 1;
      }
    }
    switch (ring) {
      case 0:
        return 0.72;
      case 1:
        return 0.88;
      default:
        return 1;
    }
  }

  double _orbitWidth(double width, double orbitalScale) {
    final double maxRadius = width * (width < 700 ? 0.36 : 0.44);
    final double edgeSafeRadius = width / 2 - (width < 700 ? 50 : 78);
    return math.max(0, math.min(maxRadius, edgeSafeRadius));
  }

  double _orbitHeight(
    double height,
    double orbitalScale,
    double maxNodeHeight,
  ) {
    final double edgeSafeHeight = height / 2 - maxNodeHeight / 2 - 10;
    return math.max(
      0,
      math.min(orbitalScale * 0.49, math.min(height * 0.39, edgeSafeHeight)),
    );
  }

  Offset? _findPlanetPosition({
    required double angle,
    required int ring,
    required Offset center,
    required double orbitWidth,
    required double orbitHeight,
    required double nodeWidth,
    required double nodeHeight,
    required double sceneWidth,
    required double sceneHeight,
    required List<Rect> occupied,
    required Offset motionPadding,
    required Rect protectedBounds,
    required double targetRadius,
  }) {
    final List<double> radii = switch (ring) {
      0 => <double>[0.72, 0.78, 0.84, 0.68, 0.90, 0.62, 0.96],
      1 => <double>[0.88, 0.82, 0.94, 0.76, 1.0, 0.70, 1.04],
      _ => <double>[1.0, 0.94, 0.88, 0.82, 0.76, 0.70, 1.06, 1.12],
    };
    final double edgePadding = sceneWidth < 700 ? 2 : 3;
    final double paddingX = motionPadding.dx + edgePadding;
    final double paddingY = motionPadding.dy + edgePadding;
    final double minX = nodeWidth / 2 + paddingX;
    final double maxX = sceneWidth - nodeWidth / 2 - paddingX;
    final double minY = nodeHeight / 2 + paddingY;
    final double maxY = sceneHeight - nodeHeight / 2 - paddingY;
    final double stepX = nodeWidth + math.max(paddingX, paddingY) * 2 + 4;
    final double stepY = nodeHeight + math.max(paddingX, paddingY) * 2 + 4;
    final List<Offset> slots = <Offset>[];
    for (double y = minY; y <= maxY; y += stepY) {
      final bool stagger = ((y - minY) / stepY).round().isOdd;
      for (double x = minX + (stagger ? stepX / 2 : 0); x <= maxX; x += stepX) {
        slots.add(Offset(x, y));
      }
    }
    slots.sort((Offset a, Offset b) {
      final double costA = _orbitCost(
        a,
        angle,
        center,
        orbitWidth,
        orbitHeight,
        targetRadius,
      );
      final double costB = _orbitCost(
        b,
        angle,
        center,
        orbitWidth,
        orbitHeight,
        targetRadius,
      );
      return costA.compareTo(costB);
    });
    for (final Offset candidate in slots) {
      final Rect bounds = Rect.fromCenter(
        center: candidate,
        width: nodeWidth,
        height: nodeHeight,
      ).inflate(math.max(paddingX, paddingY));
      if (bounds.overlaps(protectedBounds)) continue;
      if (!occupied.any(bounds.overlaps)) return candidate;
    }
    const int samples = 144;
    for (final double radius in radii) {
      for (int offset = 0; offset < samples; offset++) {
        final int signedOffset = offset == 0
            ? 0
            : (offset.isOdd ? (offset + 1) ~/ 2 : -(offset ~/ 2));
        final double candidateAngle =
            angle + signedOffset * math.pi * 2 / samples;
        final Offset candidate = Offset(
          (center.dx + math.cos(candidateAngle) * orbitWidth * radius)
              .clamp(minX, maxX)
              .toDouble(),
          (center.dy + math.sin(candidateAngle) * orbitHeight * radius)
              .clamp(minY, maxY)
              .toDouble(),
        );
        final Rect bounds = Rect.fromCenter(
          center: candidate,
          width: nodeWidth,
          height: nodeHeight,
        ).inflate(math.max(paddingX, paddingY));
        if (!occupied.any(bounds.overlaps)) return candidate;
      }
    }
    for (double y = minY; y <= maxY; y += 4) {
      for (double x = minX; x <= maxX; x += 4) {
        final Offset candidate = Offset(x, y);
        final Rect bounds = Rect.fromCenter(
          center: candidate,
          width: nodeWidth,
          height: nodeHeight,
        ).inflate(math.max(paddingX, paddingY));
        if (bounds.overlaps(protectedBounds)) continue;
        if (!occupied.any(bounds.overlaps)) return candidate;
      }
    }
    return null;
  }

  double _orbitCost(
    Offset point,
    double angle,
    Offset center,
    double orbitWidth,
    double orbitHeight,
    double targetRadius,
  ) {
    final double dx = (point.dx - center.dx) / math.max(orbitWidth, 1);
    final double dy = (point.dy - center.dy) / math.max(orbitHeight, 1);
    final double radius = math.sqrt(dx * dx + dy * dy);
    final double actualAngle = math.atan2(dy, dx);
    final double angularDistance =
        (actualAngle - angle + math.pi * 3) % (math.pi * 2) - math.pi;
    return (radius - targetRadius).abs() * 220 + angularDistance.abs() * 80;
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
            Color(0x2202091E),
            Color(0x2E07143A),
            Color(0x2903091F),
            Color(0x39010617),
          ],
          stops: <double>[0, 0.34, 0.72, 1],
        ).createShader(bounds),
    );

    final Offset center = Offset(size.width * 0.5, size.height * 0.49);
    final double scale = size.shortestSide;

    _glow(
      canvas,
      center + Offset(-scale * 0.19, -scale * 0.18),
      scale * 0.48,
      const Color(0xFF243BFF),
      0.23,
    );
    _glow(
      canvas,
      center + Offset(scale * 0.23, scale * 0.11),
      scale * 0.43,
      const Color(0xFF8B20FF),
      0.19,
    );
    _glow(
      canvas,
      center + Offset(-scale * 0.02, scale * 0.28),
      scale * 0.35,
      const Color(0xFF087DFF),
      0.16,
    );
    _glow(
      canvas,
      center + Offset(-scale * 0.32, scale * 0.12),
      scale * 0.25,
      const Color(0xFFB51DFF),
      0.13,
    );

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
          ..color =
              (ring.isEven ? const Color(0xFF6B70FF) : const Color(0xFF28A7FF))
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
          : (i % 5 == 0 ? const Color(0xFFB78CFF) : const Color(0xFFB9D7FF));
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

  void _glow(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double opacity,
  ) {
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

  void _drawSpiralArm(
    Canvas canvas,
    Offset center,
    double scale,
    double rotation,
    Color color,
    double opacity,
  ) {
    final Path path = Path();
    for (int i = 0; i <= 90; i++) {
      final double t = i / 90;
      final double angle = rotation + t * math.pi * 1.48;
      final double radius = scale * (0.10 + t * 0.43);
      final Offset point =
          center +
          Offset(
            math.cos(angle) * radius * 1.55,
            math.sin(angle) * radius * 0.76,
          );
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
    canvas.drawLine(
      point + Offset(-radius * 2, 0),
      point + Offset(radius * 2, 0),
      paint,
    );
    canvas.drawLine(
      point + Offset(0, -radius * 2),
      point + Offset(0, radius * 2),
      paint,
    );
    canvas.drawCircle(
      point,
      radius * 0.55,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _GalaxyDustPainter oldDelegate) => false;
}

/// Дополнительные редкие звёзды мерцают поверх статичного звёздного поля.
class _TwinkleStarsPainter extends CustomPainter {
  const _TwinkleStarsPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random random = math.Random(417);
    for (int i = 0; i < 34; i++) {
      final Offset point = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final double offset = random.nextDouble() * math.pi * 2;
      final double speed = 0.7 + random.nextDouble() * 1.8;
      final double pulse =
          (math.sin(phase * math.pi * 2 * speed + offset) + 1) * 0.5;
      if (pulse < 0.58) continue;

      final double intensity = (pulse - 0.58) / 0.42;
      final double radius = 0.65 + random.nextDouble() * 1.25;
      final Color color = i % 7 == 0
          ? const Color(0xFFFFD39A)
          : (i % 3 == 0 ? const Color(0xFFD5B8FF) : const Color(0xFFD9EAFF));
      final Paint glow = Paint()
        ..color = color.withValues(alpha: 0.10 + intensity * 0.34)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 2.8);
      canvas.drawCircle(point, radius * (1 + intensity * 0.7), glow);
      canvas.drawCircle(
        point,
        radius * 0.55,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35 + intensity * 0.55),
      );

      if (intensity > 0.78) {
        final Paint ray = Paint()
          ..color = color.withValues(alpha: intensity * 0.55)
          ..strokeWidth = 0.7
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          point - Offset(radius * 2.2, 0),
          point + Offset(radius * 2.2, 0),
          ray,
        );
        canvas.drawLine(
          point - Offset(0, radius * 2.2),
          point + Offset(0, radius * 2.2),
          ray,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TwinkleStarsPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _OrbitRing extends StatelessWidget {
  const _OrbitRing({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final Color tint = index == 1
        ? const Color(0xFF8D6BFF)
        : const Color(0xFF54A9FF);
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
      child:
          Stack(
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
                      Text(
                        'ДОБРО ПОЖАЛОВАТЬ',
                        style: AppTextStyles.caption(color: Colors.white),
                      ),
                      Text(
                        'В ГАЛАКТИКУ',
                        style: AppTextStyles.caption(color: Colors.white),
                      ),
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
              )
              .animate(
                onPlay: (AnimationController c) => c.repeat(reverse: true),
              )
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
    required this.maxLabelWidth,
    required this.compactLabel,
    required this.onTap,
    required this.rotationTurns,
    required this.atmospherePulse,
    required this.ringRotationTurns,
  });

  final Planet planet;
  final double size;
  final double maxLabelWidth;
  final bool compactLabel;
  final double rotationTurns;
  final double atmospherePulse;
  final double ringRotationTurns;
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
                      glow: 0.88,
                      rotationTurns: rotationTurns,
                      atmospherePulse: atmospherePulse,
                      ringRotationTurns: ringRotationTurns,
                      showRing:
                          planet.scene == PlanetScene.music ||
                          planet.scene == PlanetScene.esoteric ||
                          planet.scene == PlanetScene.finance,
                    ),
                  ),
                  Positioned(
                    top: size * 0.15,
                    child: SizedBox(
                      width: size * 0.3,
                      height: size * 0.3,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          IgnorePointer(
                            child: Container(
                              width: size * 0.72,
                              height: size * 0.72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: <Color>[
                                    planet.accent.withValues(alpha: 0.46),
                                    planet.secondary.withValues(alpha: 0.20),
                                    Colors.transparent,
                                  ],
                                  stops: const <double>[0, 0.42, 1],
                                ),
                              ),
                            ),
                          ),
                          Text(
                            planet.emoji,
                            style: TextStyle(
                              fontSize: size * 0.25,
                              shadows: <Shadow>[
                                Shadow(
                                  color: planet.accent.withValues(alpha: 0.92),
                                  blurRadius: size * 0.28,
                                ),
                                Shadow(
                                  color: planet.secondary.withValues(
                                    alpha: 0.64,
                                  ),
                                  blurRadius: size * 0.14,
                                ),
                                const Shadow(
                                  color: Color(0xAA000000),
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -size * 0.02),
              child: Container(
                key: ValueKey<String>('galaxy-label-${planet.id}'),
                constraints: BoxConstraints(maxWidth: maxLabelWidth),
                padding: EdgeInsets.symmetric(
                  horizontal: compactLabel ? 7 : 10,
                  vertical: compactLabel ? 4 : 5,
                ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label(color: Colors.white)
                          .copyWith(fontSize: compactLabel ? 10 : 11),
                    ),
                    if (!compactLabel) const SizedBox(height: 2),
                    if (!compactLabel)
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
