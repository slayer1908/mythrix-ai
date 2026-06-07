import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// MYTHRIX.AI wordmark + glyph. The glyph is a stylized geometric peak/triangle
/// with the brand gradient. Pure paint — no asset dependency.
class MythrixLogo extends StatelessWidget {
  const MythrixLogo({
    super.key,
    this.size = 32,
    this.showWordmark = true,
    this.color,
  });

  final double size;
  final bool showWordmark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MythrixGlyph(size: size),
        if (showWordmark) ...[
          SizedBox(width: size * 0.35),
          Text(
            'MYTHRIX',
            style: GoogleFonts.spaceGrotesk(
              fontSize: size * 0.82,
              fontWeight: FontWeight.w800,
              color: c,
              letterSpacing: 2.4,
              height: 1.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: size * 0.08, left: size * 0.05),
            child: ShaderMask(
              shaderCallback: (b) => AppColors.brandGradient.createShader(b),
              child: Text(
                '.AI',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: size * 0.82,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2.4,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MythrixGlyph extends StatelessWidget {
  const _MythrixGlyph({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GlyphPainter()),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = AppColors.brandGradient.createShader(rect);

    // Outer peak triangle
    final outer = Path()
      ..moveTo(size.width * 0.5, size.height * 0.08)
      ..lineTo(size.width * 0.95, size.height * 0.9)
      ..lineTo(size.width * 0.05, size.height * 0.9)
      ..close();
    canvas.drawPath(outer, paint);

    // Inner notch
    final inner = Path()
      ..moveTo(size.width * 0.5, size.height * 0.42)
      ..lineTo(size.width * 0.72, size.height * 0.82)
      ..lineTo(size.width * 0.28, size.height * 0.82)
      ..close();
    canvas.drawPath(inner, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
