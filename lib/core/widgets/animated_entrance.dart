import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// A reusable entrance animation — child fades in and gently scales up.
/// Triggered automatically on first build. Used to give every screen a
/// polished "settling in" feel.
class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.medium,
    this.fromScale = 0.96,
    this.fromOffset = const Offset(0, 0.04),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double fromScale;
  final Offset fromOffset;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        Tween<double>(begin: widget.fromScale, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: AppMotion.emphasized),
    );
    final opacity = CurvedAnimation(parent: _ctrl, curve: AppMotion.entrance);
    final offset =
        Tween<Offset>(begin: widget.fromOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: AppMotion.emphasized),
    );

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Opacity(
          opacity: opacity.value,
          child: Transform.translate(
            offset: Offset(0, offset.value.dy * 24),
            child: Transform.scale(
              scale: scale.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Helper that staggers a list of children — each entrance fires `stagger` after
/// the previous one. Used for KPI rows, grid tiles, etc.
List<Widget> staggeredEntrances(
  List<Widget> children, {
  Duration stagger = const Duration(milliseconds: 80),
  Duration initialDelay = Duration.zero,
}) {
  return [
    for (var i = 0; i < children.length; i++)
      AnimatedEntrance(
        delay: initialDelay + (stagger * i),
        child: children[i],
      ),
  ];
}
