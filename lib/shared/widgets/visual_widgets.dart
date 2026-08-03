import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/context_extensions.dart';
import '../../theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 72,
    this.animated = false,
  });

  final double size;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandTealLight,
            AppColors.brandTeal,
            AppColors.brandTealDeep,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandTeal.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.graphic_eq_rounded,
        color: Colors.white,
        size: size * 0.46,
      ),
    );

    if (!animated) return mark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.86, end: 1),
      duration: AppConstants.animationSlow,
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: mark,
    );
  }
}

class WaveVisualizer extends StatefulWidget {
  const WaveVisualizer({
    super.key,
    this.active = false,
    this.barCount = 28,
    this.height = 96,
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
      _controller.stop();
      _controller.value = 0;
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
    final barWidth = size.width / (barCount * 1.8);
    final gap = barWidth * 0.8;
    final total = barCount * barWidth + (barCount - 1) * gap;
    var x = (size.width - total) / 2;

    for (var i = 0; i < barCount; i++) {
      final wave = math.sin((progress * math.pi * 2) + i * 0.45);
      final idle = 0.18 + (i % 5) * 0.04;
      final amplitude = active ? 0.25 + (wave.abs() * 0.7) : idle;
      final h = size.height * amplitude;
      paint.color = active ? color : muted.withValues(alpha: 0.7);
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
            top: -80,
            right: -40,
            child: _GlowOrb(
              size: 220,
              color: context.colors.primary.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: _GlowOrb(
              size: 180,
              color: context.colors.secondary.withValues(alpha: 0.10),
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
