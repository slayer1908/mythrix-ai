import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Animated aurora background — slowly drifting radial gradients in brand
/// colors. Sits behind hero sections to add depth without distraction.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    this.child,
    this.intensity = 1.0,
    this.colors = const [
      AppColors.mythrixViolet,
      AppColors.mythrixCyan,
      AppColors.mythrixMagenta,
    ],
  });

  final Widget? child;
  final double intensity;
  final List<Color> colors;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return CustomPaint(
          painter: _AuroraPainter(
            t: _ctrl.value,
            colors: widget.colors,
            intensity: widget.intensity,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({
    required this.t,
    required this.colors,
    required this.intensity,
  });

  final double t;
  final List<Color> colors;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF06070C));

    for (var i = 0; i < colors.length; i++) {
      final phase = t * 2 * math.pi + (i * math.pi * 0.66);
      final cx = size.width * (0.5 + 0.35 * math.sin(phase));
      final cy = size.height * (0.5 + 0.32 * math.cos(phase * 0.8));
      final radius = math.max(size.width, size.height) * 0.55;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            colors[i].withValues(alpha: 0.28 * intensity),
            colors[i].withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
        ..blendMode = BlendMode.plus;

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.t != t;
}
