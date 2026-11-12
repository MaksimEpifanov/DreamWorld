import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Фон глубокого космоса: галактика, туманности, Млечный Путь и звёзды.
///
/// Рисуется процедурно (детерминированно) — без сетевых ресурсов. Основа
/// максимально тёмная, а цвет и глубину дают насыщенные туманности, светящееся
/// ядро галактики и плотные звёздные поля. Мягкое затемнение по краям помогает
/// читаемости интерфейса поверх, но не «глушит» цвет.
class CosmicBackground extends StatelessWidget {
  const CosmicBackground({
    super.key,
    this.seed = 42,
    this.tint,
    this.tintOpacity = 0.12,
    this.child,
  });

  static const String _backgroundAsset = 'assets/space/galaxy_background.jpg';

  final int seed;
  final Color? tint;
  final double tintOpacity;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              _backgroundAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return CustomPaint(
                      painter: _CosmosPainter(
                        seed: seed,
                        tint: null,
                        tintOpacity: 0,
                        useImageBackdrop: false,
                      ),
                    );
                  },
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              size: Size.infinite,
              painter: _CosmosPainter(
                seed: seed,
                tint: tint,
                tintOpacity: tintOpacity,
                useImageBackdrop: true,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _CosmosPainter extends CustomPainter {
  _CosmosPainter({
    required this.seed,
    required this.tint,
    required this.tintOpacity,
    required this.useImageBackdrop,
  });

  final int seed;
  final Color? tint;
  final double tintOpacity;
  final bool useImageBackdrop;

  @override
  void paint(Canvas canvas, Size size) {
    if (useImageBackdrop) {
      _paintImageBackdropShade(canvas, size);
    } else {
      final math.Random rnd = math.Random(seed);
      _paintColorWash(canvas, size);
      _paintNebulae(canvas, size, rnd);
      _paintGalaxy(canvas, size);
      _paintMilkyWay(canvas, size, rnd);
      _paintStars(canvas, size, rnd);
      _paintVignette(canvas, size);
    }
    _paintTint(canvas, size);
  }

  void _paintImageBackdropShade(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0x16030A1E));
    _paintVignette(canvas, size, opacity: 0.24);
  }

  /// Цветовая подложка: широкие насыщенные пятна, задающие богатство палитры.
  void _paintColorWash(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final List<Color> stops = <Color>[
      const Color(0xFF14142A),
      const Color(0xFF101022),
      const Color(0xFF0C0C1A),
    ];
    final List<Alignment> spots = <Alignment>[
      const Alignment(-0.6, -0.5),
      const Alignment(0.7, -0.25),
      const Alignment(-0.2, 0.65),
    ];
    for (int i = 0; i < stops.length; i++) {
      final Alignment a = spots[i];
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: a,
            radius: 0.8,
            colors: <Color>[
              stops[i].withValues(alpha: 0.16),
              stops[i].withValues(alpha: 0.0),
            ],
          ).createShader(rect),
      );
    }
  }

  /// Насыщенные туманности с высоким контрастом: тёмный космос, яркие ядра.
  void _paintNebulae(Canvas canvas, Size size, math.Random rnd) {
    // Палитра: более приглушённая, реалистичная.
    const List<Color> tints = <Color>[
      Color(0xFF6A5DFF),
      Color(0xFF4B7BFF),
      Color(0xFF9B6BFF),
      Color(0xFF6F9BFF),
    ];
    // Мягкие газовые облака (меньше и бледнее).
    for (int i = 0; i < 6; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = size.shortestSide * (0.12 + rnd.nextDouble() * 0.22);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = tints[rnd.nextInt(tints.length)].withValues(alpha: 0.14)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.38),
      );
    }
    // Яркие компактные ядра ионизированного газа.
    for (int i = 0; i < 6; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = size.shortestSide * (0.01 + rnd.nextDouble() * 0.035);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = const Color(0xFFE7E9FF).withValues(alpha: 0.24)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.7),
      );
    }
  }

  /// Наклонённая спиральная галактика: яркое ядро, диск и рукава.
  void _paintGalaxy(Canvas canvas, Size size) {
    final Offset center = Offset(size.width * 0.5, size.height * 0.49);
    final double radius = size.shortestSide * 0.49;
    final Rect bounds = Rect.fromCenter(
      center: center,
      width: radius * 2.35,
      height: radius * 1.55,
    );

    // Широкое фиолетово-синее гало вокруг центральной системы.
    canvas.drawOval(
      bounds,
      Paint()
        ..color = const Color(0xFF5145D8).withValues(alpha: 0.12)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.2),
    );
    canvas.drawOval(
      bounds.deflate(radius * 0.13),
      Paint()
        ..color = const Color(0xFF178DFF).withValues(alpha: 0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.12),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.12);

    // Два спиральных рукава, сформированных из светящихся сегментов.
    for (int arm = 0; arm < 2; arm++) {
      final Path path = Path();
      for (int i = 0; i <= 220; i++) {
        final double t = i / 220;
        final double angle = t * math.pi * 3.15 + arm * math.pi;
        final double r = radius * (0.12 + t * 0.92);
        final Offset point = Offset(
          math.cos(angle) * r * 1.12,
          math.sin(angle) * r * 0.69,
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
          ..strokeWidth = radius * 0.075
          ..strokeCap = StrokeCap.round
          ..color =
              (arm == 0 ? const Color(0xFF7B55FF) : const Color(0xFF168DFF))
                  .withValues(alpha: 0.11)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.09),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.012
          ..strokeCap = StrokeCap.round
          ..color =
              (arm == 0 ? const Color(0xFFB69AFF) : const Color(0xFF72C8FF))
                  .withValues(alpha: 0.28),
      );
    }

    // Концентрические световые кольца вокруг звезды.
    for (int i = 0; i < 5; i++) {
      final double factor = 0.28 + i * 0.17;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * factor * 2.25,
          height: radius * factor * 1.34,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 0 ? 1.8 : 1
          ..color =
              (i.isEven ? const Color(0xFF5D91FF) : const Color(0xFFB26AFF))
                  .withValues(alpha: 0.12 - i * 0.012),
      );
    }

    // Яркое ядро галактики — центр композиции под солнечной сферой UI.
    canvas.drawCircle(
      Offset.zero,
      radius * 0.25,
      Paint()
        ..color = const Color(0xFFFF9B37).withValues(alpha: 0.13)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.18),
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.11,
      Paint()
        ..color = const Color(0xFFFFD18A).withValues(alpha: 0.1)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.08),
    );

    // Звёздные скопления вдоль спиральных рукавов.
    final math.Random random = math.Random(seed + 19);
    for (int i = 0; i < 380; i++) {
      final double arm = random.nextBool() ? 0 : math.pi;
      final double t = random.nextDouble();
      final double angle = t * math.pi * 3.15 + arm;
      final double r = radius * (0.12 + t * 0.92);
      final Offset point = Offset(
        math.cos(angle) * r * 1.12 +
            (random.nextDouble() - 0.5) * radius * 0.09,
        math.sin(angle) * r * 0.69 +
            (random.nextDouble() - 0.5) * radius * 0.09,
      );
      final double dot = random.nextDouble() * 1.35 + 0.25;
      canvas.drawCircle(
        point,
        dot,
        Paint()
          ..color =
              (i % 5 == 0 ? const Color(0xFFFFD6B0) : const Color(0xFFD7DFFF))
                  .withValues(alpha: 0.18 + random.nextDouble() * 0.52),
      );
    }
    canvas.restore();
  }

  /// Млечный Путь: широкая туманная полоса с пылевыми жилами и звёздами.
  void _paintMilkyWay(Canvas canvas, Size size, math.Random rnd) {
    final double diagonal = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    const double angle = 0.44;
    final Offset start = Offset(
      size.width * 0.5 - math.cos(angle) * diagonal * 0.6,
      size.height * 0.5 - math.sin(angle) * diagonal * 0.6,
    );
    final Offset end = Offset(
      size.width * 0.5 + math.cos(angle) * diagonal * 0.6,
      size.height * 0.5 + math.sin(angle) * diagonal * 0.6,
    );

    // Слои свечения: от широкого фиолетово-синего к тёплому белому ядру.
    final List<List<Object>> layers = <List<Object>>[
      <Object>[size.shortestSide * 0.26, 0.07, const Color(0xFF2F2A6B)],
      <Object>[size.shortestSide * 0.16, 0.09, const Color(0xFF5A56B3)],
      <Object>[size.shortestSide * 0.09, 0.11, const Color(0xFFB9B6F0)],
      <Object>[size.shortestSide * 0.05, 0.14, const Color(0xFFE7E5FA)],
      <Object>[size.shortestSide * 0.018, 0.2, const Color(0xFFFFFFFF)],
    ];
    for (final List<Object> layer in layers) {
      final double w = layer[0] as double;
      final double a = layer[1] as double;
      final Color c = layer[2] as Color;
      canvas.drawLine(
        start,
        end,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round
          ..color = c.withValues(alpha: a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.5),
      );
    }

    // Тёмные пылевые прожилки вдоль полосы (несколько, разной кривизны).
    for (int i = 0; i < 2; i++) {
      final Offset shift = Offset(
        (rnd.nextDouble() - 0.5) * size.shortestSide * 0.06,
        (rnd.nextDouble() - 0.5) * size.shortestSide * 0.06,
      );
      canvas.drawLine(
        start + shift,
        end + shift,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * (0.012 + i * 0.01)
          ..color = const Color(0xFF04030A).withValues(alpha: 0.4)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            size.shortestSide * 0.018,
          ),
      );
    }

    // Плотное звёздное скопление вдоль полосы.
    for (int i = 0; i < 260; i++) {
      final double t = rnd.nextDouble();
      final Offset p = Offset.lerp(start, end, t)!;
      final double spread =
          size.shortestSide * (0.016 + rnd.nextDouble() * 0.07);
      final Offset jitter = Offset(
        (rnd.nextDouble() - 0.5) * spread,
        (rnd.nextDouble() - 0.5) * spread,
      );
      final double r = rnd.nextDouble() * 0.9 + 0.18;
      canvas.drawCircle(
        p + jitter,
        r,
        Paint()
          ..color = Colors.white.withValues(
            alpha: 0.28 + rnd.nextDouble() * 0.42,
          ),
      );
    }
  }

  void _paintStars(Canvas canvas, Size size, math.Random rnd) {
    final int count = (size.width * size.height / 1600).clamp(160, 900).toInt();
    for (int i = 0; i < count; i++) {
      final Offset p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = rnd.nextDouble() * 1.1 + 0.2;
      final double alpha = 0.22 + rnd.nextDouble() * 0.5;
      final double hue = rnd.nextDouble();
      final Color color = hue > 0.92
          ? const Color(0xFFB9C8FF)
          : (hue > 0.88 ? const Color(0xFFFFE3C0) : Colors.white);
      canvas.drawCircle(p, r, Paint()..color = color.withValues(alpha: alpha));
    }
    // Яркие звёзды с крестовым ореолом и лучами.
    for (int i = 0; i < 6; i++) {
      final Offset p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double glow = size.shortestSide * (0.01 + rnd.nextDouble() * 0.014);
      canvas.drawCircle(
        p,
        glow,
        Paint()
          ..color = const Color(0xFFD8E0FF).withValues(alpha: 0.14)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow * 0.8),
      );
      final Paint ray = Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = 0.8;
      canvas.drawLine(p - Offset(glow, 0), p + Offset(glow, 0), ray);
      canvas.drawLine(p - Offset(0, glow), p + Offset(0, glow), ray);
      canvas.drawCircle(
        p,
        rnd.nextDouble() * 1.0 + 1.1,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }
  }

  /// Мягкое затемнение по самому краю — читаемость интерфейса без потери цвета.
  void _paintVignette(Canvas canvas, Size size, {double opacity = 0.52}) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.15,
          colors: <Color>[
            Colors.transparent,
            const Color(0xFF000000).withValues(alpha: opacity),
          ],
          stops: const <double>[0.72, 1.0],
        ).createShader(rect),
    );
  }

  void _paintTint(Canvas canvas, Size size) {
    final Color? t = tint;
    if (t == null || tintOpacity <= 0) return;
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 1.1,
          colors: <Color>[
            t.withValues(alpha: tintOpacity),
            t.withValues(alpha: 0.0),
          ],
          stops: const <double>[0.0, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _CosmosPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.tint != tint ||
      oldDelegate.tintOpacity != tintOpacity;
}
