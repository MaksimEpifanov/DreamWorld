import 'dart:math';

import 'package:flutter/material.dart';

class CompatibilityRing extends StatefulWidget {
  const CompatibilityRing({
    super.key,
    required this.percent,
    this.size = 80,
    this.strokeWidth = 8,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  final double percent;
  final double size;
  final double strokeWidth;
  final Duration animationDuration;

  @override
  State<CompatibilityRing> createState() => _CompatibilityRingState();
}

class _CompatibilityRingState extends State<CompatibilityRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.percent.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CompatibilityRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percent.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color secondary = Theme.of(context).colorScheme.secondary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _CompatibilityRingPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
              color1: primary,
              color2: secondary,
            ),
            child: Center(
              child: Text(
                '${(_animation.value * 100).round()}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompatibilityRingPainter extends CustomPainter {
  _CompatibilityRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color1,
    required this.color2,
  });

  final double progress;
  final double strokeWidth;
  final Color color1;
  final Color color2;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 2 * pi - pi / 2,
        colors: <Color>[
          color1,
          color2,
        ],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CompatibilityRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2;
  }
}
