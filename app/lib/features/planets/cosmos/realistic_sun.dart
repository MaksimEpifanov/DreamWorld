import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'planet_art.dart';

/// Фотореалистичное солнце: фактура плазмы и солнечные пятна.
///
/// Строго без лучей, линзовых бликов и гало — только мягкий объёмный свет
/// вокруг диска. Если найден `assets/space/sun.png`, используется он.
class RealisticSun extends StatefulWidget {
  const RealisticSun({super.key, required this.size, this.glow = 0.5});

  /// Диаметр диска солнца.
  final double size;

  /// Сила мягкого объёмного свечения (0 — выключено).
  final double glow;

  @override
  State<RealisticSun> createState() => _RealisticSunState();
}

class _RealisticSunState extends State<RealisticSun>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;
    final double glow = widget.glow;
    final double canvas = size * (1 + glow);
    return RepaintBoundary(
      child: SizedBox(
        width: canvas,
        height: canvas,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            if (glow > 0)
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  final double pulse =
                      (math.sin(_controller.value * 2 * math.pi) + 1) / 2;
                  return Transform.scale(
                    scale: 0.96 + pulse * 0.045,
                    child: Container(
                      width: size * (1 + glow * 0.9),
                      height: size * (1 + glow * 0.9),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            const Color(
                              0xFFFFD27A,
                            ).withValues(alpha: glow * (0.40 + pulse * 0.18)),
                            const Color(
                              0xFFFF7130,
                            ).withValues(alpha: glow * (0.14 + pulse * 0.08)),
                            Colors.transparent,
                          ],
                          stops: const <double>[0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                final double pulse =
                    (math.sin(_controller.value * 2 * math.pi + 0.7) + 1) / 2;
                return Transform.scale(
                  scale: 0.992 + pulse * 0.016,
                  child: child,
                );
              },
              child: Image.asset(
                sunAssetPath,
                width: size,
                height: size,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return CustomPaint(
                        size: Size.square(size),
                        painter: const _SunPainter(),
                      );
                    },
              ),
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) => CustomPaint(
                  size: Size.square(size * 1.32),
                  painter: _CoronaPainter(phase: _controller.value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoronaPainter extends CustomPainter {
  const _CoronaPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide * 0.38;
    for (int i = 0; i < 9; i++) {
      final double angle = i * math.pi * 2 / 9 + phase * math.pi * 2;
      final double flutter = math.sin(phase * math.pi * 2 + i * 1.7) * 0.08;
      final double inner = radius * (0.92 + flutter);
      final double outer = radius * (1.06 + flutter);
      final Offset start =
          center + Offset(math.cos(angle), math.sin(angle)) * inner;
      final Offset end =
          center + Offset(math.cos(angle), math.sin(angle)) * outer;
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = const Color(0xFFFFD88A).withValues(alpha: 0.10)
          ..strokeWidth = size.shortestSide * 0.012
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CoronaPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _SunPainter extends CustomPainter {
  const _SunPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.shortestSide / 2;
    final Offset center = size.center(Offset.zero);
    final Rect disc = Rect.fromCircle(center: center, radius: radius);
    final math.Random rnd = math.Random(7);

    canvas.save();
    canvas.clipPath(Path()..addOval(disc));

    // Базовая сфера плазмы — яркое чистое ядро.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.25, -0.3),
          radius: 1.05,
          colors: <Color>[
            Color(0xFFFFFFFF),
            Color(0xFFFFF9DC),
            Color(0xFFFFE48A),
            Color(0xFFFFC24D),
            Color(0xFFF59A2B),
          ],
          stops: <double>[0.0, 0.28, 0.6, 0.85, 1.0],
        ).createShader(disc),
    );

    // Мягкая грануляция плазмы — только светлые «кипящие» пятна.
    for (int i = 0; i < 90; i++) {
      final double a = rnd.nextDouble() * math.pi * 2;
      final double d = rnd.nextDouble() * radius * 0.95;
      final Offset p = center + Offset(math.cos(a) * d, math.sin(a) * d * 0.9);
      canvas.drawCircle(
        p,
        radius * (0.04 + rnd.nextDouble() * 0.08),
        Paint()
          ..color = const Color(0xFFFFF6D0).withValues(alpha: 0.12)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.05),
      );
    }

    // Едва заметные солнечные пятна — не нарушают чисто́ту диска.
    for (int i = 0; i < 5; i++) {
      final double a = rnd.nextDouble() * math.pi * 2;
      final double d = rnd.nextDouble() * radius * 0.6;
      final Offset p = center + Offset(math.cos(a) * d, math.sin(a) * d);
      final double spot = radius * (0.04 + rnd.nextDouble() * 0.05);
      canvas.drawCircle(
        p,
        spot,
        Paint()
          ..color = const Color(0xFFD97A1E).withValues(alpha: 0.18)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, spot * 0.5),
      );
    }

    // Мягкий объём к краю — лимб (тёплый, а не грязный).
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          radius: 1.0,
          colors: <Color>[
            Colors.transparent,
            Colors.transparent,
            const Color(0xFFFF9A2E).withValues(alpha: 0.35),
            const Color(0xFFE0701A).withValues(alpha: 0.55),
          ],
          stops: const <double>[0.62, 0.85, 0.95, 1.0],
        ).createShader(disc),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SunPainter oldDelegate) => false;
}
