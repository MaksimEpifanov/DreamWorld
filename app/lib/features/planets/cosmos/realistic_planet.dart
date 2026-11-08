import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models/planet.dart';
import 'planet_art.dart';

/// Фотореалистичная (процедурная) планета-шар с тенью от солнца.
///
/// Свет всегда идёт от солнца — задаётся через [lightAlignment] (вектор
/// к центру системы). Если для планеты найден PNG (`assets/planets/<id>.png`),
/// он используется как текстура поверхности; иначе рисуется процедурная
/// поверхность: океаны/материки/кратеры, терминатор, блик и атмосфера.
///
/// [rotationTurns] — медленный поворот поверхности (0..1 — полный оборот).
/// Поворачивается только текстура, освещение остаётся привязано к солнцу.
class RealisticPlanet extends StatelessWidget {
  const RealisticPlanet({
    super.key,
    required this.planet,
    required this.size,
    this.lightAlignment = const Alignment(-0.6, -0.5),
    this.showRing = false,
    this.glow = 0.55,
    this.rotationTurns = 0,
    this.atmospherePulse = 0,
    this.ringRotationTurns = 0,
  });

  final Planet planet;

  /// Диаметр шара.
  final double size;

  /// Направление света (от солнца к планете — со знаком минус).
  final Alignment lightAlignment;

  /// Показывать ли кольца (газовые/металлические планеты).
  final bool showRing;

  /// Сила внешнего свечения (0 — выключено).
  final double glow;

  /// Текущий угол поворота поверхности в оборотах (0..1).
  final double rotationTurns;

  /// Пульсация свечения атмосферы (0..1).
  final double atmospherePulse;

  /// Угол вращения колец вокруг оси планеты (в оборотах).
  final double ringRotationTurns;

  @override
  Widget build(BuildContext context) {
    final double ringPad = showRing ? size * 0.5 : 0;
    final double canvas = size + ringPad;

    return RepaintBoundary(
      child: SizedBox(
        width: canvas,
        height: canvas,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            if (glow > 0)
              Container(
                width: size * 1.35,
                height: size * 1.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      planet.primary.withValues(alpha: glow * 0.5),
                      planet.secondary.withValues(alpha: glow * 0.18),
                      Colors.transparent,
                    ],
                    stops: const <double>[0.0, 0.5, 1.0],
                  ),
                ),
              ),
            Image.asset(
              planetAssetPath(planet),
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              frameBuilder: (
                BuildContext context,
                Widget child,
                int? frame,
                bool wasSynchronouslyLoaded,
              ) {
                if (frame == null || rotationTurns == 0) return child;
                return Transform.rotate(
                  angle: rotationTurns * 2 * math.pi,
                  child: child,
                );
              },
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return CustomPaint(
                  size: Size.square(size),
                  painter: _PlanetPainter(
                    planet: planet,
                    lightAlignment: lightAlignment,
                    showRing: showRing,
                    rotationTurns: rotationTurns,
                    atmospherePulse: atmospherePulse,
                    ringRotationTurns: ringRotationTurns,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanetPainter extends CustomPainter {
  _PlanetPainter({
    required this.planet,
    required this.lightAlignment,
    required this.showRing,
    required this.rotationTurns,
    required this.atmospherePulse,
    required this.ringRotationTurns,
  });

  final Planet planet;
  final Alignment lightAlignment;
  final bool showRing;
  final double rotationTurns;
  final double atmospherePulse;
  final double ringRotationTurns;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.shortestSide / 2;
    final Offset center = size.center(Offset.zero);
    final Rect sphere = Rect.fromCircle(center: center, radius: radius);

    final SurfacePalette palette = paletteFor(planet);
    final math.Random rnd = math.Random(planet.id.hashCode);

    if (showRing) _paintRingBack(canvas, center, radius, palette);

    // Слой поверхности, обрезанный по кругу.
    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    // Поворачиваем только текстуру поверхности — освещение остаётся
    // привязано к солнцу и не «крутится» вместе с планетой.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationTurns * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);
    _paintSurface(canvas, size, radius, palette, rnd);
    canvas.restore();

    _paintLighting(
      canvas,
      size,
      radius,
      palette,
    );
    canvas.restore();

    if (showRing) _paintRingFront(canvas, center, radius, palette);

    _paintAtmosphere(canvas, sphere, palette, atmospherePulse);
  }

  /// Поверхность: пятна-материки, борозды облаков и мелкая детализация.
  void _paintSurface(
    Canvas canvas,
    Size size,
    double radius,
    SurfacePalette palette,
    math.Random rnd,
  ) {
    final double side = size.shortestSide;
    final Offset center = size.center(Offset.zero);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 1.1,
          colors: <Color>[
            palette.light,
            palette.base,
            palette.dark,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Неровные материки и облачные пятна вместо однообразных кругов.
    for (int i = 0; i < 23; i++) {
      final double angle = rnd.nextDouble() * math.pi * 2;
      final double distance = rnd.nextDouble() * radius * 0.78;
      final Offset origin = center +
          Offset(math.cos(angle) * distance, math.sin(angle) * distance);
      final double blobRadius = radius * (0.075 + rnd.nextDouble() * 0.16);
      final Path blob = Path();
      const int vertices = 9;
      for (int pointIndex = 0; pointIndex < vertices; pointIndex++) {
        final double theta = pointIndex * math.pi * 2 / vertices;
        final double irregularity = 0.68 + rnd.nextDouble() * 0.52;
        final Offset point = origin +
            Offset(
              math.cos(theta) * blobRadius * irregularity,
              math.sin(theta) * blobRadius * irregularity * 0.72,
            );
        if (pointIndex == 0) {
          blob.moveTo(point.dx, point.dy);
        } else {
          blob.lineTo(point.dx, point.dy);
        }
      }
      blob.close();
      final bool bright = rnd.nextBool();
      canvas.drawPath(
        blob,
        Paint()
          ..color = (bright ? palette.light : palette.dark)
              .withValues(alpha: bright ? 0.42 : 0.38)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            radius * 0.025,
          ),
      );
    }

    // Мягкие атмосферные облака создают глубину поверхности.
    for (int i = 0; i < 8; i++) {
      final double angle = i * math.pi * 2 / 8 + 0.24;
      final Offset cloudCenter = center +
          Offset(math.cos(angle) * radius * 0.48,
              math.sin(angle) * radius * 0.34);
      final Rect cloudRect = Rect.fromCircle(
        center: cloudCenter,
        radius: radius * 0.25,
      );
      canvas.drawOval(
        cloudRect,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              palette.light.withValues(alpha: 0.22),
              Colors.transparent,
            ],
          ).createShader(cloudRect),
      );
    }

    // Полосы (для газовых/облачных планет) — плавные дуги.
    if (surfaceForScene(planet.scene) == PlanetSurface.gas ||
        surfaceForScene(planet.scene) == PlanetSurface.cloud) {
      for (int i = 0; i < 7; i++) {
        final double y = center.dy - radius + radius * (0.15 + i * 0.12);
        final Paint band = Paint()
          ..color = (i.isEven ? palette.light : palette.dark)
              .withValues(alpha: 0.28)
          ..strokeWidth = radius * (0.05 + rnd.nextDouble() * 0.06)
          ..style = PaintingStyle.stroke;
        final Path path = Path();
        path.moveTo(center.dx - radius, y);
        for (double x = -radius; x <= radius; x += radius / 4) {
          path.quadraticBezierTo(
            center.dx + x,
            y + math.sin((x / radius) * math.pi) * radius * 0.04,
            center.dx + x + radius / 4,
            y,
          );
        }
        canvas.drawPath(path, band);
      }
    }

    // Кратеры/детали — мелкие тёмные точки.
    for (int i = 0; i < 40; i++) {
      final double a = rnd.nextDouble() * math.pi * 2;
      final double d = rnd.nextDouble() * radius * 0.95;
      final Offset p = center + Offset(math.cos(a) * d, math.sin(a) * d);
      canvas.drawCircle(
        p,
        radius * (0.01 + rnd.nextDouble() * 0.03),
        Paint()..color = palette.dark.withValues(alpha: 0.35),
      );
    }

    // Белые полярные шапки у некоторых планет.
    if (surfaceForScene(planet.scene) == PlanetSurface.ice ||
        surfaceForScene(planet.scene) == PlanetSurface.ocean) {
      final Paint cap = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.06);
      canvas.drawCircle(
        Offset(center.dx, center.dy - radius * 0.85),
        radius * 0.3,
        cap,
      );
      canvas.drawCircle(
        Offset(center.dx, center.dy + radius * 0.85),
        radius * 0.26,
        cap,
      );
    }

    // Игнорируем возможный неиспользуемый параметр side.
    assert(side > 0);
  }

  /// Освещение: блик у источника света и мягкая тень на обратной стороне.
  void _paintLighting(
    Canvas canvas,
    Size size,
    double radius,
    SurfacePalette palette,
  ) {
    final Offset center = size.center(Offset.zero);
    final Rect sphere = Rect.fromCircle(center: center, radius: radius);
    final Offset lightOffset =
        Offset(lightAlignment.x, lightAlignment.y) * radius * 0.9;

    // Терминатор — тёмный градиент со стороны, противоположной свету.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(lightAlignment.x, lightAlignment.y),
          radius: 1.25,
          colors: <Color>[
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.72),
          ],
          stops: const <double>[0.35, 0.62, 1.0],
        ).createShader(sphere),
    );

    // Мягкий блик в точке, обращённой к солнцу.
    canvas.drawCircle(
      center + lightOffset,
      radius * 0.32,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0.55),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: center + lightOffset, radius: radius * 0.34),
        ),
    );

    // Узкий направленный блик подчёркивает кривизну поверхности.
    final Rect specularRect = Rect.fromCircle(
      center: center + lightOffset * 0.72,
      radius: radius * 0.78,
    );
    canvas.drawOval(
      specularRect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
            -lightAlignment.x * 0.55,
            -lightAlignment.y * 0.55,
          ),
          colors: <Color>[
            Colors.white.withValues(alpha: 0.13),
            Colors.white.withValues(alpha: 0.035),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.42, 1],
        ).createShader(specularRect),
    );
  }

  /// Задняя часть кольца (за планетой).
  void _paintRingBack(
    Canvas canvas,
    Offset center,
    double radius,
    SurfacePalette palette,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.transform(
      (Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(1.2)
            ..rotateZ(-0.35 + ringRotationTurns * 2 * math.pi))
          .storage,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 3.1,
        height: radius * 3.1,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.16
        ..color = palette.light.withValues(alpha: 0.32),
    );
    canvas.restore();
  }

  /// Передняя часть кольца (поверх планеты).
  void _paintRingFront(
    Canvas canvas,
    Offset center,
    double radius,
    SurfacePalette palette,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.clipRect(Rect.fromLTRB(-radius * 2, 0, radius * 2, radius * 2));
    canvas.transform(
      (Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(1.2)
            ..rotateZ(-0.35 + ringRotationTurns * 2 * math.pi))
          .storage,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 3.1,
        height: radius * 3.1,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.16
        ..color = palette.light.withValues(alpha: 0.42),
    );
    canvas.restore();
  }

  /// Тонкая атмосферная кромка вокруг планеты.
  void _paintAtmosphere(Canvas canvas, Rect sphere, SurfacePalette palette,
      double pulse) {
    final double radius = sphere.width / 2;
    canvas.drawCircle(
      sphere.center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sphere.width * (0.03 + pulse * 0.012)
        ..color = palette.light.withValues(alpha: 0.38 + pulse * 0.20)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.outer,
          sphere.width * (0.035 + pulse * 0.02),
        ),
    );
    canvas.drawArc(
      Rect.fromCircle(center: sphere.center, radius: radius * 1.015),
      math.pi * 1.08,
      math.pi * 0.78,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sphere.width * 0.012
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.28 + pulse * 0.20),
    );
  }

  @override
  bool shouldRepaint(covariant _PlanetPainter oldDelegate) {
    return oldDelegate.planet != planet ||
        oldDelegate.lightAlignment != lightAlignment ||
        oldDelegate.showRing != showRing ||
        oldDelegate.rotationTurns != rotationTurns ||
        oldDelegate.atmospherePulse != atmospherePulse ||
        oldDelegate.ringRotationTurns != ringRotationTurns;
  }
}
