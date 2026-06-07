import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum MythrixButtonSize { small, medium, large }

/// Premium gradient CTA. Use sparingly — usually one per screen.
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.size = MythrixButtonSize.medium,
    this.gradient = AppColors.brandGradient,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final MythrixButtonSize size;
  final Gradient gradient;
  final bool expand;
  final bool loading;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hover = false;
  bool _press = false;

  EdgeInsets get _padding {
    switch (widget.size) {
      case MythrixButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs);
      case MythrixButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2);
      case MythrixButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case MythrixButtonSize.small:
        return 13;
      case MythrixButtonSize.medium:
        return 14;
      case MythrixButtonSize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: _padding,
      decoration: BoxDecoration(
        gradient: disabled
            ? LinearGradient(
                colors: [
                  Colors.grey.withValues(alpha: 0.4),
                  Colors.grey.withValues(alpha: 0.3),
                ],
              )
            : widget.gradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: !disabled && _hover
            ? [
                BoxShadow(
                  color: AppColors.mythrixViolet.withValues(alpha: 0.45),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.mythrixViolet.withValues(alpha: 0.25),
                  blurRadius: 14,
                  spreadRadius: -6,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.loading)
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          else if (widget.icon != null) ...[
            Icon(widget.icon, color: Colors.white, size: _fontSize + 4),
            AppSpacing.hGapXs,
          ],
          Text(
            widget.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          if (widget.trailingIcon != null) ...[
            AppSpacing.hGapXs,
            Icon(widget.trailingIcon, color: Colors.white, size: _fontSize + 4),
          ],
        ],
      ),
    );

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _press = true),
        onTapUp: disabled ? null : (_) => setState(() => _press = false),
        onTapCancel: disabled ? null : () => setState(() => _press = false),
        onTap: disabled ? null : widget.onPressed,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: _press ? 0.97 : 1.0,
          child: child,
        ),
      ),
    );
  }
}
