import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72, this.animated = false});

  final double size;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AlarmMarkPainter(
          gradient: AppColors.brandGradient,
          shadowColor: AppColors.brandTeal.withValues(alpha: 0.28),
        ),
      ),
    );

    if (!animated) return mark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.88, end: 1),
      duration: AppConstants.animationSlow,
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: mark,
    );
  }
}

class _AlarmMarkPainter extends CustomPainter {
  _AlarmMarkPainter({required this.gradient, required this.shadowColor});

  final Gradient gradient;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = size.shortestSide * 0.28;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(2),
      Radius.circular(radius),
    );

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawRRect(rrect.shift(const Offset(0, 8)), shadowPaint);

    final fill = Paint()..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, fill);

    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect.deflate(1), stroke);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.shortestSide * 0.22;
    final white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.045
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), outer, white);

    final hand = Paint()
      ..color = Colors.white
      ..strokeWidth = size.shortestSide * 0.045
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - outer * 0.55), hand);
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + outer * 0.42, cy + outer * 0.12),
      hand,
    );

    final bell = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx - outer * 0.95, cy - outer * 0.85),
        width: outer * 0.7,
        height: outer * 0.7,
      ),
      -2.2,
      1.6,
      false,
      bell,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx + outer * 0.95, cy - outer * 0.85),
        width: outer * 0.7,
        height: outer * 0.7,
      ),
      -0.6,
      1.6,
      false,
      bell,
    );
  }

  @override
  bool shouldRepaint(covariant _AlarmMarkPainter oldDelegate) => false;
}

class WaveVisualizer extends StatefulWidget {
  const WaveVisualizer({
    super.key,
    this.active = false,
    this.barCount = 26,
    this.height = 88,
  });

  final bool active;
  final int barCount;
  final double height;

  @override
  State<WaveVisualizer> createState() => _WaveVisualizerState();
}

class _WaveVisualizerState extends State<WaveVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant WaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _WavePainter(
              progress: _controller.value,
              active: widget.active,
              barCount: widget.barCount,
              color: context.colors.primary,
              muted: context.colors.outline,
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.progress,
    required this.active,
    required this.barCount,
    required this.color,
    required this.muted,
  });

  final double progress;
  final bool active;
  final int barCount;
  final Color color;
  final Color muted;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    final barWidth = size.width / (barCount * 1.85);
    final gap = barWidth * 0.85;
    final total = barCount * barWidth + (barCount - 1) * gap;
    var x = (size.width - total) / 2;

    for (var i = 0; i < barCount; i++) {
      final wave = math.sin((progress * math.pi * 2) + i * 0.42);
      final idle = 0.18 + (i % 5) * 0.035;
      final amplitude = active ? 0.28 + (wave.abs() * 0.65) : idle;
      final h = size.height * amplitude;
      paint.color = active ? color : muted.withValues(alpha: 0.65);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + barWidth / 2, size.height / 2),
            width: barWidth,
            height: h,
          ),
          const Radius.circular(8),
        ),
        paint,
      );
      x += barWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.active != active ||
        oldDelegate.color != color;
  }
}

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.lightGradient = AppColors.splashGradientLight,
    this.darkGradient = AppColors.splashGradientDark,
  });

  final Widget child;
  final Gradient lightGradient;
  final Gradient darkGradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: context.isDark ? darkGradient : lightGradient,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -50,
            child: _GlowOrb(
              size: 220,
              color: context.colors.primary.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -40,
            child: _GlowOrb(
              size: 180,
              color: context.colors.primary.withValues(alpha: 0.07),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
