import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../data/models/planet.dart';

class PlanetHeroOrb extends StatelessWidget {
  const PlanetHeroOrb({super.key, required this.planet, this.compact = false});

  final Planet planet;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double orbSize = compact ? 64 : 132;
    final double outerSize = compact ? 96 : 190;
    final Widget orb =
        Container(
              width: orbSize,
              height: orbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.4, -0.4),
                  radius: 0.95,
                  colors: <Color>[
                    planet.secondary,
                    planet.primary,
                    planet.primary.withValues(alpha: 0.6),
                  ],
                  stops: const <double>[0.0, 0.62, 1.0],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: planet.primary.withValues(alpha: 0.65),
                    blurRadius: compact ? 24 : 56,
                    spreadRadius: compact ? 1 : 4,
                  ),
                  BoxShadow(
                    color: planet.secondary.withValues(alpha: 0.32),
                    blurRadius: compact ? 36 : 84,
                    spreadRadius: compact ? 0 : 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                planet.emoji,
                style: TextStyle(fontSize: compact ? 28 : 58),
              ),
            )
            .animate(
              onPlay: (AnimationController controller) =>
                  controller.repeat(reverse: true),
            )
            .moveY(
              begin: compact ? -3 : -6,
              end: compact ? 3 : 6,
              duration: 2800.ms,
              curve: Curves.easeInOut,
            );

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child:
                CustomPaint(
                      painter: _OrbitPainter(
                        color: planet.accent,
                        dotColor: planet.secondary,
                        compact: compact,
                      ),
                    )
                    .animate(
                      onPlay: (AnimationController controller) =>
                          controller.repeat(),
                    )
                    .rotate(duration: 24000.ms),
          ),
          orb
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: Offset(compact ? 0.85 : 0.7, compact ? 0.85 : 0.7),
                end: const Offset(1, 1),
                duration: 700.ms,
                curve: Curves.easeOutBack,
              ),
        ],
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({
    required this.color,
    required this.dotColor,
    this.compact = false,
  });

  final Color color;
  final Color dotColor;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.96,
      height: size.height * 0.68,
    );
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = compact ? 0.8 : 1.4
        ..color = color.withValues(alpha: 0.28),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 0.6,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = compact ? 1.2 : 2.4
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(rect.center.dx, rect.top),
      compact ? 3.5 : 7,
      Paint()..color = dotColor.withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      Offset(rect.center.dx, rect.top),
      compact ? 1.7 : 3.4,
      Paint()..color = dotColor,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.compact != compact;
  }
}
