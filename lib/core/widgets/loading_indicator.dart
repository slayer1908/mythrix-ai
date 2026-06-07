import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Branded loading orb — an animated conic gradient ring.
class MythrixLoader extends StatefulWidget {
  const MythrixLoader({super.key, this.size = 36});
  final double size;

  @override
  State<MythrixLoader> createState() => _MythrixLoaderState();
}

class _MythrixLoaderState extends State<MythrixLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Transform.rotate(
        angle: _c.value * 2 * math.pi,
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _RingPainter(),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          AppColors.mythrixViolet,
          AppColors.mythrixCyan,
          AppColors.mythrixMagenta,
          AppColors.mythrixViolet,
        ],
      ).createShader(rect);
    canvas.drawArc(
      Rect.fromCircle(center: rect.center, radius: size.width / 2 - 2),
      0,
      math.pi * 1.6,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
