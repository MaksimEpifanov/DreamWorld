import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/index.dart';
import '../../../../core/widgets/cosmic_background.dart';
import '../../../../data/models/planet.dart';
import 'realistic_planet.dart';
import 'realistic_sun.dart';

/// Орбитальный каталог: солнце в центре и планеты по эллиптическим орбитам.
///
/// Раскладка считается от РЕАЛЬНЫХ размеров области. Размер планет/солнца
/// берётся от меньшей стороны (чтобы всё влезало по высоте на широком
/// экране ПК), а орбиты растягиваются по ширине. Кольца разнесены, углы
/// чередуются — планеты не наслаиваются и не пересекаются.
///
/// Каждая планета медленно вращается на месте (лёгкое живое движение),
/// навигация при этом не затрагивается: нажатие обрабатывает [GestureDetector]
/// поверх визуала.
class OrbitalCatalog extends StatelessWidget {
  const OrbitalCatalog({
    super.key,
    required this.planets,
    required this.onPlanetTap,
    this.showLabels = true,
  });

  final List<Planet> planets;
  final ValueChanged<Planet> onPlanetTap;
  final bool showLabels;

  /// Количество планет на каждом кольце (в сумме — все планеты).
  static List<int> _ringCounts(int total) {
    if (total <= 6) return <int>[total];
    return <int>[6, 7, total - 13];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : constraints.maxWidth;
        // Центр сцены слегка поднят: снизу остаётся больше места под подписи
        // нижних планет, чтобы они заведомо не упирались в край экрана.
        final Offset center = Offset(w / 2, h * 0.47);

        // Опорный размер — меньшая сторона области (безопасно по высоте).
        final double base = math.min(w, h);

        final List<int> rings = _ringCounts(planets.length);
        final int ringCount = rings.length;

        // Компактное солнце: чистое и яркое, но не «съедающее» место планет.
        final double sunSize = (base * 0.18).clamp(48.0, 150.0);

        // Максимальный размер сферы планеты.
        final double maxPlanet = (sunSize * 0.42).clamp(16.0, 44.0);

        // Полный след планеты на экране (кольца/свечение выходят за сферу).
        final double maxFootprint = maxPlanet * 1.5;
        // Высота подписи под планетой (с запасом).
        final double labelHeight = maxPlanet * 0.55 + 18;

        // Полуоси орбит. По ВЕРТИКАЛИ обязательно оставляем place под
        // половину следа планеты сверху/снизу И подпись снизу — тогда ни одна
        // планета и её подпись не выйдут за пределы области.
        final double verticalNeed = maxFootprint / 2 + labelHeight;
        final double roomTop = center.dy;
        final double roomBottom = h - center.dy;
        final double maxRy = math.max(
          20.0,
          math.min(roomTop, roomBottom) - verticalNeed,
        );
        final double maxRx = math.max(20.0, w / 2 - maxFootprint / 2 - 10);

        // Кольца разнесены по радиусу так, чтобы соседние не наслаивались.
        final double inner = 0.46;
        final List<double> radiiX = <double>[
          for (int i = 0; i < ringCount; i++)
            ringCount == 1
                ? maxRx * 0.8
                : maxRx * (inner + (1 - inner) * (i / (ringCount - 1))),
        ];

        int index = 0;
        final List<Widget> children = <Widget>[];

        for (int r = 0; r < ringCount; r++) {
          final int count = rings[r];
          final double rx = radiiX[r];
          final double ry = rx * (maxRy / maxRx).clamp(0.35, 1.0);

          // Размер сферы планеты ограничен ещё и шагом по дуге, чтобы планеты
          // одного кольца не смыкались (с учётом полного следа).
          final double arcGap = (2 * math.pi * rx / count) * 0.62;
          final double planetSize = math.min(
            sunSize * (0.42 - r * 0.04),
            math.min(arcGap / 1.5, maxPlanet),
          ).clamp(18.0, 46.0);
          final double footprint = planetSize * 1.5;
          final double labelWidth = planetSize * 3.4;

          // Кольцо орбиты.
          children.add(
            Positioned(
              left: center.dx - rx,
              top: center.dy - ry,
              width: rx * 2,
              height: ry * 2,
              child: CustomPaint(
                painter: _CatalogOrbitPainter(
                  color: Theme.of(context).colorScheme.primary,
                  emphasis: 1 - r / ringCount,
                ),
              ),
            ),
          );

          // Углы колец чередуются, чтобы планеты разных орбит не совпадали
          // по направлению и не перекрывались.
          final double angleOffset = r * (math.pi / count);
          for (int i = 0; i < count && index < planets.length; i++, index++) {
            final Planet planet = planets[index];
            final double angle = angleOffset + (2 * math.pi / count) * i;
            final double px = center.dx + math.cos(angle) * rx;
            final double py = center.dy + math.sin(angle) * ry;

            // Лёгкое вращение: у каждой планеты своя скорость и фаза.
            final double speed = 0.9 + (index % 5) * 0.14;
            final double phase = (index * 0.17) % 1.0;

            children.add(
              Positioned(
                left: px - footprint / 2,
                top: py - footprint / 2,
                width: footprint,
                height: footprint,
                child: _RotatingPlanet(
                  planet: planet,
                  size: planetSize,
                  speed: speed,
                  phase: phase,
                  lightAlignment: Alignment(
                    -math.cos(angle),
                    -math.sin(angle),
                  ),
                  onTap: () => onPlanetTap(planet),
                ),
              ),
            );

            if (showLabels) {
              children.add(
                Positioned(
                  left: px - labelWidth / 2,
                  top: py + planetSize / 2 + 2,
                  width: labelWidth,
                  child: IgnorePointer(
                    child: Center(child: _PlanetLabel(planet: planet)),
                  ),
                ),
              );
            }
          }
        }

        return CosmicBackground(
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                ...children,
                Positioned(
                  left: center.dx - sunSize / 2,
                  top: center.dy - sunSize / 2,
                  width: sunSize,
                  height: sunSize,
                  child: RealisticSun(size: sunSize, glow: 0.55),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Планета с лёгким постоянным вращением поверхности.
///
/// Анимация касается только визуала; обработчик нажатия не двигается,
/// поэтому навигация работает как раньше.
class _RotatingPlanet extends StatefulWidget {
  const _RotatingPlanet({
    required this.planet,
    required this.size,
    required this.speed,
    required this.phase,
    required this.lightAlignment,
    required this.onTap,
  });

  final Planet planet;
  final double size;
  final double speed;
  final double phase;
  final Alignment lightAlignment;
  final VoidCallback onTap;

  @override
  State<_RotatingPlanet> createState() => _RotatingPlanetState();
}

class _RotatingPlanetState extends State<_RotatingPlanet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (12000 / widget.speed).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double turns = (widget.phase + _controller.value) % 1.0;
          return RealisticPlanet(
            planet: widget.planet,
            size: widget.size,
            lightAlignment: widget.lightAlignment,
            showRing: _hasRing(widget.planet),
            glow: 0.4,
            rotationTurns: turns,
          );
        },
      ),
    );
  }

  bool _hasRing(Planet planet) {
    switch (planet.scene) {
      case PlanetScene.cinema:
      case PlanetScene.technology:
      case PlanetScene.esoteric:
      case PlanetScene.collecting:
      case PlanetScene.other:
        return true;
      default:
        return false;
    }
  }
}

/// Подпись под планетой.
class _PlanetLabel extends StatelessWidget {
  const _PlanetLabel({required this.planet});

  final Planet planet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.45),
        borderRadius: AppRadius.pillAll,
        border: Border.all(
          color: planet.accent.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        planet.shortName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyles.caption(color: AppColors.textPrimary),
      ),
    );
  }
}

/// Тонкое наклонённое кольцо орбиты.
class _CatalogOrbitPainter extends CustomPainter {
  _CatalogOrbitPainter({required this.color, required this.emphasis});

  final Color color;
  final double emphasis;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Rect rect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.10 + 0.12 * emphasis),
    );
  }

  @override
  bool shouldRepaint(covariant _CatalogOrbitPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.emphasis != emphasis;
}
