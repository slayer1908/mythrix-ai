import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers/brand_profile_providers.dart';
import '../../data/providers/chat_providers.dart';

/// Floating "Ask Mythrix" launcher — bottom-right FAB on every screen.
/// Tints itself with the user's brand color and gently breathes when idle.
class ChatLauncher extends ConsumerStatefulWidget {
  const ChatLauncher({super.key});

  @override
  ConsumerState<ChatLauncher> createState() => _ChatLauncherState();
}

class _ChatLauncherState extends ConsumerState<ChatLauncher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final open = ref.watch(chatDrawerOpenProvider);
    final profile = ref.watch(brandProfileProvider);
    final accent = profile?.accentColor ?? AppColors.mythrixViolet;

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: open ? 0.0 : 1.0,
      curve: Curves.easeOutCubic,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          // When hovered, freeze the pulse at full strength so the orb feels
          // alive but responsive to mouse intent.
          final t = _hover ? 1.0 : _pulse.value;
          final glow = 0.45 + 0.25 * t; // 0.45 → 0.70
          final scale = 1.0 + (_hover ? 0.05 : 0.02 * t); // tiny breath
          return Transform.scale(
            scale: scale,
            child: MouseRegion(
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              cursor: SystemMouseCursors.click,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent,
                      accent.withValues(alpha: 0.7),
                      AppColors.mythrixCyan,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: glow),
                      blurRadius: 30 + 12 * t,
                      spreadRadius: -2 + 4 * t,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => ref.read(chatDrawerOpenProvider.notifier).state = true,
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
