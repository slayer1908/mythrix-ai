import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A signature MYTHRIX surface: frosted glass with a subtle inner border and an
/// optional aurora glow. Adapts to light/dark theme.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.blur = 28,
    this.tintOpacity,
    this.glowColor,
    this.glowIntensity = 0.0,
    this.border = true,
    this.onTap,
    this.hoverable = false,
    this.gradient,
    this.height,
    this.width,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final double? tintOpacity;
  final Color? glowColor;
  final double glowIntensity;
  final bool border;
  final VoidCallback? onTap;
  final bool hoverable;
  final Gradient? gradient;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = (tintOpacity ?? (isDark ? 0.55 : 0.85));

    final bg = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  scheme.surfaceContainer.withValues(alpha: tint),
                  scheme.surfaceContainerLow.withValues(alpha: tint * 0.85),
                ]
              : [
                  Colors.white.withValues(alpha: tint),
                  Colors.white.withValues(alpha: tint * 0.92),
                ],
        );

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            gradient: bg,
            borderRadius: BorderRadius.circular(radius),
            border: border
                ? Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );

    if (glowIntensity > 0 && glowColor != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.35 * glowIntensity),
              blurRadius: 36 * glowIntensity,
              spreadRadius: 2,
            ),
          ],
        ),
        child: content,
      );
    }

    if (onTap != null || hoverable) {
      return _HoverWrap(
        radius: radius,
        onTap: onTap,
        hoverable: hoverable,
        child: content,
      );
    }

    return content;
  }
}

class _HoverWrap extends StatefulWidget {
  const _HoverWrap({
    required this.child,
    required this.radius,
    required this.onTap,
    required this.hoverable,
  });

  final Widget child;
  final double radius;
  final VoidCallback? onTap;
  final bool hoverable;

  @override
  State<_HoverWrap> createState() => _HoverWrapState();
}

class _HoverWrapState extends State<_HoverWrap> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: _hover && widget.hoverable ? 1.012 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: _hover && widget.hoverable
                  ? [
                      BoxShadow(
                        color: AppColors.mythrixViolet.withValues(alpha: 0.22),
                        blurRadius: 24,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
