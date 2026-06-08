import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/mythrix_logo.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/brand_profile_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted || _navigated) return;
      debugPrint('[Splash] Safety-net fallback → /login');
      _goto(AppRoutes.login);
    });
  }

  Future<void> _boot() async {
    debugPrint('[Splash] boot start');
    String? userId;

    try {
      final user = await AuthService.instance.restoreSession();
      userId = user?.id;
      debugPrint('[Splash] restoreSession ok, user=${user?.email ?? "null"}');

      // If signed in, pull brand profile(s) from Firestore so a fresh device
      // / cleared browser cache hydrates from cloud instead of going through
      // onboarding again.
      if (user != null) {
        try {
          await ref.read(brandProfileProvider.notifier).syncFromCloud();
          debugPrint('[Splash] Firestore sync complete');
        } catch (e) {
          debugPrint('[Splash] Firestore sync failed: $e');
        }
      }
    } catch (e, s) {
      debugPrint('[Splash] restoreSession threw: $e\n$s');
    }

    try {
      ref.read(authReadyProvider.notifier).state = true;
      debugPrint('[Splash] authReady=true');
    } catch (e) {
      debugPrint('[Splash] could not set authReady: $e');
    }

    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    _goto(userId == null ? AppRoutes.login : AppRoutes.dashboard);
  }

  void _goto(String route) {
    if (_navigated) return;
    _navigated = true;
    debugPrint('[Splash] go → $route');
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MythrixLogo(size: 56),
                AppSpacing.vGapXl,
                SizedBox(
                  width: 180,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
                AppSpacing.vGapMd,
                Text(
                  'Calibrating your growth engine…',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
