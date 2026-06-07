import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/auth_providers.dart';
import '../../data/providers/brand_profile_providers.dart';
import '../../features/ads_manager/ads_manager_screen.dart';
import '../../features/ads_manager/network_ads_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/audiences/audiences_screen.dart';
import '../../features/automations/automation_rules_screen.dart';
import '../../features/conversions/conversions_screen.dart';
import '../../features/billing/billing_screen.dart';
import '../../features/brand_assets/brand_assets_screen.dart';
import '../../features/content_studio/content_studio_screen.dart';
import '../../features/creative_studio/creative_studio_screen.dart';
import '../../features/crm/crm_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/email_marketing/email_marketing_screen.dart';
import '../../features/integrations/integrations_screen.dart';
import '../../features/landing/landing_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/onboarding/onboarding_wizard.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/seo/seo_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/social_scheduler/social_scheduler_screen.dart';
import '../../features/team/team_screen.dart';
import '../navigation/app_shell.dart';

class AppRoutes {
  AppRoutes._();
  static const landing = '/';
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';

  static const dashboard = '/app/dashboard';
  static const content = '/app/content';
  static const creative = '/app/creative';
  static const social = '/app/social';
  static const ads = '/app/ads';
  static const analytics = '/app/analytics';
  static const seo = '/app/seo';
  static const email = '/app/email';
  static const crm = '/app/crm';
  static const automations = '/app/automations';
  static const brand = '/app/brand';
  static const team = '/app/team';
  static const settings = '/app/settings';
  static const billing = '/app/billing';
  static const library = '/app/library';
  static const integrations = '/app/integrations';
  static const conversions = '/app/conversions';
  static const audiences = '/app/audiences';
  static const onboarding = '/onboarding';
}

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref
      ..listen(authStateProvider, (_, __) => notifyListeners())
      ..listen(authReadyProvider, (_, __) => notifyListeners())
      ..listen(brandProfileProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final ready = ref.read(authReadyProvider);
      if (!ready) return null;

      final user = ref.read(currentUserProvider);
      final loggedIn = user != null;
      final loc = state.matchedLocation;
      final atLanding = loc == AppRoutes.landing;
      final atAuthFlow = loc == AppRoutes.login ||
          loc == AppRoutes.signup ||
          loc == AppRoutes.splash;
      final atOnboarding = loc == AppRoutes.onboarding;

      // Public landing page — anyone can see it, logged-in OR not.
      if (atLanding) return null;

      if (!loggedIn && !atAuthFlow) return AppRoutes.login;
      if (loggedIn && atAuthFlow) {
        // Logged-in but landed on auth flow — decide where to send them.
        final done = ref.read(onboardingDoneProvider);
        return done ? AppRoutes.dashboard : AppRoutes.onboarding;
      }
      // Catch the case of a logged-in user navigating elsewhere without
      // having finished onboarding (e.g. bookmark to /app/dashboard).
      if (loggedIn && !atOnboarding) {
        final done = ref.read(onboardingDoneProvider);
        if (!done) return AppRoutes.onboarding;
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.landing, builder: (_, __) => const LandingScreen()),
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup, builder: (_, __) => const SignupScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingWizard()),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
          GoRoute(path: AppRoutes.content, builder: (_, __) => const ContentStudioScreen()),
          GoRoute(path: AppRoutes.creative, builder: (_, __) => const CreativeStudioScreen()),
          GoRoute(path: AppRoutes.social, builder: (_, __) => const SocialSchedulerScreen()),
          GoRoute(path: AppRoutes.ads, builder: (_, __) => const AdsManagerScreen()),
          GoRoute(
            path: '${AppRoutes.ads}/:networkId',
            builder: (_, state) => NetworkAdsScreen(
              networkId: state.pathParameters['networkId'] ?? 'google-ads',
            ),
          ),
          GoRoute(path: AppRoutes.analytics, builder: (_, __) => const AnalyticsScreen()),
          GoRoute(path: AppRoutes.seo, builder: (_, __) => const SeoScreen()),
          GoRoute(path: AppRoutes.email, builder: (_, __) => const EmailMarketingScreen()),
          GoRoute(path: AppRoutes.crm, builder: (_, __) => const CrmScreen()),
          GoRoute(path: AppRoutes.automations, builder: (_, __) => const AutomationRulesScreen()),
          GoRoute(path: AppRoutes.brand, builder: (_, __) => const BrandAssetsScreen()),
          GoRoute(path: AppRoutes.team, builder: (_, __) => const TeamScreen()),
          GoRoute(path: AppRoutes.settings, builder: (_, __) => const SettingsScreen()),
          GoRoute(path: AppRoutes.billing, builder: (_, __) => const BillingScreen()),
          GoRoute(path: AppRoutes.library, builder: (_, __) => const LibraryScreen()),
          GoRoute(path: AppRoutes.integrations, builder: (_, __) => const IntegrationsScreen()),
          GoRoute(path: AppRoutes.conversions, builder: (_, __) => const ConversionsScreen()),
          GoRoute(path: AppRoutes.audiences, builder: (_, __) => const AudiencesScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.matchedLocation}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
});
