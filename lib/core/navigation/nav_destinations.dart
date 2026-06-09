import 'package:flutter/material.dart';

import '../router/app_router.dart';

class NavDestination {
  const NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.badge,
    this.shortcut,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final String? badge;
  final String? shortcut;
}

class NavSection {
  const NavSection({required this.title, required this.destinations});
  final String title;
  final List<NavDestination> destinations;
}

const List<NavSection> kNavSections = [
  NavSection(title: 'Overview', destinations: [
    NavDestination(
      label: 'Mission Control',
      icon: Icons.dashboard_customize_outlined,
      activeIcon: Icons.dashboard_customize_rounded,
      route: AppRoutes.dashboard,
      shortcut: 'G D',
    ),
    NavDestination(
      label: 'Analytics',
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      route: AppRoutes.analytics,
      shortcut: 'G A',
    ),
  ]),
  NavSection(title: 'Create', destinations: [
    NavDestination(
      label: 'Content Studio',
      icon: Icons.edit_note_outlined,
      activeIcon: Icons.edit_note,
      route: AppRoutes.content,
      shortcut: 'G C',
    ),
    NavDestination(
      label: 'Creative Studio',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
      route: AppRoutes.creative,
      badge: 'NEW',
    ),
    NavDestination(
      label: 'Brand Assets',
      icon: Icons.palette_outlined,
      activeIcon: Icons.palette_rounded,
      route: AppRoutes.brand,
    ),
  ]),
  NavSection(title: 'Distribute', destinations: [
    NavDestination(
      label: 'Social Scheduler',
      icon: Icons.event_outlined,
      activeIcon: Icons.event_rounded,
      route: AppRoutes.social,
      shortcut: 'G S',
    ),
    NavDestination(
      label: 'Ads Manager',
      icon: Icons.campaign_outlined,
      activeIcon: Icons.campaign_rounded,
      route: AppRoutes.ads,
      shortcut: 'G P',
    ),
    NavDestination(
      label: 'Email Marketing',
      icon: Icons.alternate_email_outlined,
      activeIcon: Icons.alternate_email_rounded,
      route: AppRoutes.email,
    ),
    NavDestination(
      label: 'SEO',
      icon: Icons.travel_explore_outlined,
      activeIcon: Icons.travel_explore_rounded,
      route: AppRoutes.seo,
    ),
  ]),
  NavSection(title: 'Grow', destinations: [
    NavDestination(
      label: 'Library',
      icon: Icons.collections_bookmark_outlined,
      activeIcon: Icons.collections_bookmark_rounded,
      route: AppRoutes.library,
      badge: 'NEW',
    ),
    NavDestination(
      label: 'CRM',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
      route: AppRoutes.crm,
    ),
    NavDestination(
      label: 'Automations',
      icon: Icons.bolt_outlined,
      activeIcon: Icons.bolt_rounded,
      route: AppRoutes.automations,
    ),
    NavDestination(
      label: 'Conversions',
      icon: Icons.track_changes_outlined,
      activeIcon: Icons.track_changes_rounded,
      route: AppRoutes.conversions,
      badge: 'NEW',
    ),
    NavDestination(
      label: 'Audiences',
      icon: Icons.people_alt_outlined,
      activeIcon: Icons.people_alt_rounded,
      route: AppRoutes.audiences,
      badge: 'NEW',
    ),
  ]),
  NavSection(title: 'Workspace', destinations: [
    NavDestination(
      label: 'Integrations',
      icon: Icons.hub_outlined,
      activeIcon: Icons.hub_rounded,
      route: AppRoutes.integrations,
      badge: 'NEW',
    ),
    NavDestination(
      label: 'Team',
      icon: Icons.person_2_outlined,
      activeIcon: Icons.person_2_rounded,
      route: AppRoutes.team,
    ),
    NavDestination(
      label: 'Pricing',
      icon: Icons.attach_money_rounded,
      activeIcon: Icons.attach_money_rounded,
      route: AppRoutes.pricing,
    ),
    NavDestination(
      label: 'Billing',
      icon: Icons.credit_card_outlined,
      activeIcon: Icons.credit_card_rounded,
      route: AppRoutes.billing,
    ),
    NavDestination(
      label: 'Settings',
      icon: Icons.tune_outlined,
      activeIcon: Icons.tune_rounded,
      route: AppRoutes.settings,
      shortcut: 'G ,',
    ),
  ]),
];

/// Mobile bottom-nav uses a condensed set of the most important destinations.
const List<NavDestination> kMobilePrimary = [
  NavDestination(
    label: 'Home',
    icon: Icons.dashboard_customize_outlined,
    activeIcon: Icons.dashboard_customize_rounded,
    route: AppRoutes.dashboard,
  ),
  NavDestination(
    label: 'Create',
    icon: Icons.auto_awesome_outlined,
    activeIcon: Icons.auto_awesome_rounded,
    route: AppRoutes.content,
  ),
  NavDestination(
    label: 'Schedule',
    icon: Icons.event_outlined,
    activeIcon: Icons.event_rounded,
    route: AppRoutes.social,
  ),
  NavDestination(
    label: 'Ads',
    icon: Icons.campaign_outlined,
    activeIcon: Icons.campaign_rounded,
    route: AppRoutes.ads,
  ),
  NavDestination(
    label: 'Insights',
    icon: Icons.insights_outlined,
    activeIcon: Icons.insights_rounded,
    route: AppRoutes.analytics,
  ),
];
