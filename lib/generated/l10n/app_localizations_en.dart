// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mythrix';

  @override
  String get appTagline => 'Marketing on autopilot.';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToWorkspace => 'Sign in to your Mythrix workspace.';

  @override
  String get workEmail => 'Work email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create an account';

  @override
  String get newToMythrix => 'New to Mythrix?';

  @override
  String get createWorkspace => 'Create your Mythrix workspace';

  @override
  String get freeTrial => 'Free 14-day trial. No card required.';

  @override
  String get yourName => 'Your name';

  @override
  String get workspace => 'Workspace';

  @override
  String minCharsRequired(int count) {
    return 'Min $count characters';
  }

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get required => 'Required';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get dashboardSubtitle =>
      'Here\'s what Mythrix has been up to overnight.';

  @override
  String get launchWithMythrix => 'Launch with Mythrix';

  @override
  String lastNDays(int n) {
    return 'Last $n days';
  }

  @override
  String get export => 'Export';

  @override
  String get navMissionControl => 'Mission Control';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navContentStudio => 'Content Studio';

  @override
  String get navCreativeStudio => 'Creative Studio';

  @override
  String get navBrandAssets => 'Brand Assets';

  @override
  String get navSocialScheduler => 'Social Scheduler';

  @override
  String get navAdsManager => 'Ads Manager';

  @override
  String get navEmailMarketing => 'Email Marketing';

  @override
  String get navSeo => 'SEO';

  @override
  String get navCrm => 'CRM';

  @override
  String get navAutomations => 'Automations';

  @override
  String get navTeam => 'Team';

  @override
  String get navSettings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get generate => 'Generate';

  @override
  String get approve => 'Approve';

  @override
  String get review => 'Review';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading…';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get upgradePlan => 'Upgrade plan';

  @override
  String get currentPlan => 'Current plan';

  @override
  String get manageBilling => 'Manage billing';
}
