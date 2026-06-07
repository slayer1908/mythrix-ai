import 'package:flutter/material.dart';

/// What kind of platform this integration is.
enum IntegrationCategory {
  ads,
  crm,
  analytics,
  email,
  ecommerce,
  social,
  productivity,
  payments,
  storage,
  ai,
}

extension IntegrationCategoryX on IntegrationCategory {
  String get label {
    switch (this) {
      case IntegrationCategory.ads: return 'Ad networks';
      case IntegrationCategory.crm: return 'CRM';
      case IntegrationCategory.analytics: return 'Analytics';
      case IntegrationCategory.email: return 'Email';
      case IntegrationCategory.ecommerce: return 'E-commerce';
      case IntegrationCategory.social: return 'Social publishing';
      case IntegrationCategory.productivity: return 'Productivity';
      case IntegrationCategory.payments: return 'Payments';
      case IntegrationCategory.storage: return 'Storage';
      case IntegrationCategory.ai: return 'AI providers';
    }
  }

  IconData get icon {
    switch (this) {
      case IntegrationCategory.ads: return Icons.campaign_rounded;
      case IntegrationCategory.crm: return Icons.contacts_rounded;
      case IntegrationCategory.analytics: return Icons.insights_rounded;
      case IntegrationCategory.email: return Icons.mail_outline_rounded;
      case IntegrationCategory.ecommerce: return Icons.shopping_bag_outlined;
      case IntegrationCategory.social: return Icons.share_rounded;
      case IntegrationCategory.productivity: return Icons.workspaces_outline;
      case IntegrationCategory.payments: return Icons.payments_rounded;
      case IntegrationCategory.storage: return Icons.folder_special_outlined;
      case IntegrationCategory.ai: return Icons.auto_awesome_rounded;
    }
  }
}

enum IntegrationStatus { connected, available, comingSoon }

extension IntegrationStatusX on IntegrationStatus {
  String get label {
    switch (this) {
      case IntegrationStatus.connected: return 'Connected';
      case IntegrationStatus.available: return 'Available';
      case IntegrationStatus.comingSoon: return 'Coming soon';
    }
  }

  Color get color {
    switch (this) {
      case IntegrationStatus.connected: return const Color(0xFF34D399);
      case IntegrationStatus.available: return const Color(0xFF60A5FA);
      case IntegrationStatus.comingSoon: return const Color(0xFFFBBF24);
    }
  }
}

/// A single platform Mythrix can plug into.
class Integration {
  const Integration({
    required this.id,
    required this.name,
    required this.category,
    required this.tagline,
    required this.color,
    this.status = IntegrationStatus.available,
    this.phase = 'Phase 4',
    this.features = const [],
    this.docsUrl,
  });

  final String id;
  final String name;
  final IntegrationCategory category;
  final String tagline;
  final Color color;
  final IntegrationStatus status;
  final String phase;
  final List<String> features;
  final String? docsUrl;

  Integration copyWith({IntegrationStatus? status}) => Integration(
        id: id,
        name: name,
        category: category,
        tagline: tagline,
        color: color,
        status: status ?? this.status,
        phase: phase,
        features: features,
        docsUrl: docsUrl,
      );
}

/// The canonical catalog of every platform Mythrix supports or plans to.
const kIntegrationCatalog = <Integration>[
  // === Ad networks ===
  Integration(
    id: 'google-ads',
    name: 'Google Ads',
    category: IntegrationCategory.ads,
    tagline: 'Search, Performance Max, Display, YouTube, Demand Gen',
    color: Color(0xFF4285F4),
    status: IntegrationStatus.available,
    phase: 'Phase 4',
    features: ['Search', 'Performance Max', 'Display Network', 'YouTube Ads', 'Demand Gen', 'Smart Shopping'],
  ),
  Integration(
    id: 'google-lsa',
    name: 'Google Local Services Ads',
    category: IntegrationCategory.ads,
    tagline: 'Pay-per-lead ads for local service businesses',
    color: Color(0xFF34A853),
    phase: 'Phase 4',
    features: ['Lead pay model', 'Google Guaranteed badge', 'Booking integration', 'Review syndication'],
  ),
  Integration(
    id: 'meta-ads',
    name: 'Meta Ads',
    category: IntegrationCategory.ads,
    tagline: 'Facebook, Instagram, WhatsApp, Audience Network',
    color: Color(0xFF1877F2),
    phase: 'Phase 4',
    features: ['Advantage+ Shopping', 'Lookalike audiences', 'Conversions API (CAPI)', 'Catalog ads'],
  ),
  Integration(
    id: 'tiktok-ads',
    name: 'TikTok Ads',
    category: IntegrationCategory.ads,
    tagline: 'Spark ads, in-feed, branded effects',
    color: Color(0xFFEE1D52),
    phase: 'Phase 4',
    features: ['Spark Ads', 'TikTok Shop', 'Smart Performance', 'Creator Marketplace'],
  ),
  Integration(
    id: 'linkedin-ads',
    name: 'LinkedIn Ads',
    category: IntegrationCategory.ads,
    tagline: 'B2B lead gen, sponsored content, InMail',
    color: Color(0xFF0A66C2),
    phase: 'Phase 4',
    features: ['Sponsored Content', 'Message Ads', 'Lead Gen Forms', 'Account-based targeting'],
  ),
  Integration(
    id: 'x-ads',
    name: 'X Ads',
    category: IntegrationCategory.ads,
    tagline: 'Promoted posts, takeovers, trends',
    color: Color(0xFF000000),
    phase: 'Phase 4',
    features: ['Promoted posts', 'Pre-roll video', 'Takeovers', 'Conversation targeting'],
  ),
  Integration(
    id: 'microsoft-ads',
    name: 'Microsoft Ads',
    category: IntegrationCategory.ads,
    tagline: 'Bing, Yahoo, AOL search + audience network',
    color: Color(0xFF00BCF2),
    phase: 'Phase 4',
    features: ['Bing search', 'Microsoft Audience Network', 'LinkedIn targeting', 'PMax for Microsoft'],
  ),
  Integration(
    id: 'reddit-ads',
    name: 'Reddit Ads',
    category: IntegrationCategory.ads,
    tagline: 'Subreddit, conversation, interest targeting',
    color: Color(0xFFFF4500),
    phase: 'Phase 4',
    features: ['Subreddit targeting', 'Conversation ads', 'Free-form ads', 'Promoted user posts'],
  ),
  Integration(
    id: 'pinterest-ads',
    name: 'Pinterest Ads',
    category: IntegrationCategory.ads,
    tagline: 'Idea pins, shopping, video for discovery',
    color: Color(0xFFE60023),
    phase: 'Phase 4',
    features: ['Idea Pins', 'Shopping ads', 'Video views', 'Catalog feeds'],
  ),
  Integration(
    id: 'snapchat-ads',
    name: 'Snapchat Ads',
    category: IntegrationCategory.ads,
    tagline: 'AR lenses, story ads, Spotlight',
    color: Color(0xFFFFFC00),
    phase: 'Phase 4',
    features: ['AR Lens Studio', 'Story ads', 'Spotlight', 'Collection ads'],
  ),
  Integration(
    id: 'amazon-dsp',
    name: 'Amazon DSP',
    category: IntegrationCategory.ads,
    tagline: 'Programmatic display + Sponsored Products',
    color: Color(0xFFFF9900),
    phase: 'Phase 5',
    features: ['Sponsored Products', 'Sponsored Brands', 'Sponsored Display', 'DSP audiences'],
  ),

  // === CRM ===
  Integration(
    id: 'hubspot',
    name: 'HubSpot',
    category: IntegrationCategory.crm,
    tagline: 'Marketing + Sales hub with native CRM',
    color: Color(0xFFFF7A59),
    phase: 'Phase 2',
    features: ['Contact sync', 'Deal pipelines', 'Email sequences', 'Lead scoring', 'Workflows'],
  ),
  Integration(
    id: 'salesforce',
    name: 'Salesforce',
    category: IntegrationCategory.crm,
    tagline: 'Enterprise CRM + Process Builder + Einstein AI',
    color: Color(0xFF00A1E0),
    phase: 'Phase 2',
    features: ['Lead / Opportunity sync', 'Flow Builder', 'Einstein AI scoring', 'AppExchange'],
  ),
  Integration(
    id: 'zoho-crm',
    name: 'Zoho CRM',
    category: IntegrationCategory.crm,
    tagline: 'Affordable CRM bundled with 35+ apps',
    color: Color(0xFFEB0029),
    phase: 'Phase 2',
    features: ['Lead pipelines', 'Zoho Campaigns sync', 'Zia AI assistant', 'Blueprint workflows'],
  ),
  Integration(
    id: 'pipedrive',
    name: 'Pipedrive',
    category: IntegrationCategory.crm,
    tagline: 'Visual sales pipeline for SMB teams',
    color: Color(0xFF000000),
    phase: 'Phase 2',
    features: ['Visual pipelines', 'Email tracking', 'Activity automation', 'Insights dashboards'],
  ),
  Integration(
    id: 'monday',
    name: 'monday.com Sales CRM',
    category: IntegrationCategory.crm,
    tagline: 'Visual board-based CRM',
    color: Color(0xFFFF3D57),
    phase: 'Phase 3',
    features: ['Custom boards', 'Lead capture', 'Form automation', 'Sales dashboards'],
  ),

  // === Analytics ===
  Integration(
    id: 'ga4',
    name: 'Google Analytics 4',
    category: IntegrationCategory.analytics,
    tagline: 'Event-based product + marketing analytics',
    color: Color(0xFFE37400),
    phase: 'Phase 2',
    features: ['Event sync', 'Custom audiences', 'Attribution', 'BigQuery export'],
  ),
  Integration(
    id: 'mixpanel',
    name: 'Mixpanel',
    category: IntegrationCategory.analytics,
    tagline: 'Product analytics with funnels & cohorts',
    color: Color(0xFF7856FF),
    phase: 'Phase 3',
    features: ['Event tracking', 'Funnel analysis', 'Cohort retention', 'Reverse ETL'],
  ),
  Integration(
    id: 'amplitude',
    name: 'Amplitude',
    category: IntegrationCategory.analytics,
    tagline: 'Behavioral analytics + A/B testing',
    color: Color(0xFF1E61F0),
    phase: 'Phase 3',
    features: ['Behavioral cohorts', 'Predictive ML', 'A/B test analysis', 'Notebooks'],
  ),
  Integration(
    id: 'segment',
    name: 'Segment',
    category: IntegrationCategory.analytics,
    tagline: 'CDP for unified event tracking',
    color: Color(0xFF52BD94),
    phase: 'Phase 3',
    features: ['Connections', 'Protocols', 'Personas', 'Reverse ETL'],
  ),

  // === Email ===
  Integration(
    id: 'mailchimp',
    name: 'Mailchimp',
    category: IntegrationCategory.email,
    tagline: 'Email + SMS marketing for SMB',
    color: Color(0xFFFFE01B),
    phase: 'Phase 3',
    features: ['Audience sync', 'Campaign builder', 'Customer journeys', 'Predictive segmentation'],
  ),
  Integration(
    id: 'klaviyo',
    name: 'Klaviyo',
    category: IntegrationCategory.email,
    tagline: 'Email + SMS for e-commerce',
    color: Color(0xFF000000),
    phase: 'Phase 3',
    features: ['Flow builder', 'Predictive analytics', 'SMS', 'Reviews'],
  ),
  Integration(
    id: 'sendgrid',
    name: 'SendGrid',
    category: IntegrationCategory.email,
    tagline: 'Transactional + marketing email delivery',
    color: Color(0xFF1A82E2),
    phase: 'Phase 3',
    features: ['Transactional API', 'Marketing campaigns', 'Email validation', 'Dynamic templates'],
  ),
  Integration(
    id: 'resend',
    name: 'Resend',
    category: IntegrationCategory.email,
    tagline: 'Developer-first email API',
    color: Color(0xFF000000),
    phase: 'Phase 3',
    features: ['Domain auth', 'React Email templates', 'Webhooks', 'Audiences'],
  ),

  // === E-commerce ===
  Integration(
    id: 'shopify',
    name: 'Shopify',
    category: IntegrationCategory.ecommerce,
    tagline: 'Store data, product feeds, customer sync',
    color: Color(0xFF95BF47),
    phase: 'Phase 3',
    features: ['Product catalog', 'Order events', 'Customer sync', 'Checkout extensibility'],
  ),
  Integration(
    id: 'woocommerce',
    name: 'WooCommerce',
    category: IntegrationCategory.ecommerce,
    tagline: 'WordPress e-commerce stack',
    color: Color(0xFF96588A),
    phase: 'Phase 3',
    features: ['Product sync', 'Order webhooks', 'Coupon automation', 'Subscription support'],
  ),
  Integration(
    id: 'bigcommerce',
    name: 'BigCommerce',
    category: IntegrationCategory.ecommerce,
    tagline: 'Headless and SaaS commerce',
    color: Color(0xFF121118),
    phase: 'Phase 5',
    features: ['Catalog sync', 'Multi-storefront', 'Channel manager', 'Webhooks'],
  ),

  // === Social publishing ===
  Integration(
    id: 'meta-graph',
    name: 'Instagram + Facebook',
    category: IntegrationCategory.social,
    tagline: 'Native publishing via Meta Graph API',
    color: Color(0xFFE1306C),
    phase: 'Phase 5',
    features: ['Schedule posts', 'Stories', 'Reels', 'Insights pull'],
  ),
  Integration(
    id: 'linkedin-pages',
    name: 'LinkedIn Pages',
    category: IntegrationCategory.social,
    tagline: 'Native company-page publishing',
    color: Color(0xFF0A66C2),
    phase: 'Phase 5',
    features: ['Post scheduling', 'Document posts', 'Polls', 'Page analytics'],
  ),
  Integration(
    id: 'tiktok-content',
    name: 'TikTok Content API',
    category: IntegrationCategory.social,
    tagline: 'Direct post via TikTok Content API',
    color: Color(0xFF000000),
    phase: 'Phase 5',
    features: ['Direct upload', 'Hashtag insights', 'Sound trends', 'Creator marketplace'],
  ),

  // === Payments ===
  Integration(
    id: 'stripe',
    name: 'Stripe',
    category: IntegrationCategory.payments,
    tagline: 'Billing, subscriptions, revenue analytics',
    color: Color(0xFF635BFF),
    phase: 'Phase 1',
    features: ['Subscription billing', 'Sigma analytics', 'Customer portal', 'Tax automation'],
  ),
  Integration(
    id: 'paddle',
    name: 'Paddle',
    category: IntegrationCategory.payments,
    tagline: 'Merchant-of-record SaaS billing',
    color: Color(0xFFFFD300),
    phase: 'Phase 3',
    features: ['Sales tax handling', 'Subscription billing', 'Dunning', 'Revenue analytics'],
  ),
  Integration(
    id: 'paypal',
    name: 'PayPal',
    category: IntegrationCategory.payments,
    tagline: 'Checkout, subscriptions, payouts',
    color: Color(0xFF003087),
    phase: 'Phase 5',
    features: ['Checkout', 'Subscriptions', 'Payouts', 'Fraud signals'],
  ),

  // === Productivity ===
  Integration(
    id: 'slack',
    name: 'Slack',
    category: IntegrationCategory.productivity,
    tagline: 'Send alerts + digests to your team',
    color: Color(0xFF4A154B),
    phase: 'Phase 2',
    features: ['Channel notifications', 'Daily digest', 'Bot commands', 'Approval flows'],
  ),
  Integration(
    id: 'notion',
    name: 'Notion',
    category: IntegrationCategory.productivity,
    tagline: 'Sync briefs, content calendar, retros',
    color: Color(0xFF000000),
    phase: 'Phase 3',
    features: ['Database sync', 'Calendar export', 'Doc sync', 'Wiki search'],
  ),
  Integration(
    id: 'gsheets',
    name: 'Google Sheets',
    category: IntegrationCategory.productivity,
    tagline: 'Export reports, two-way data sync',
    color: Color(0xFF34A853),
    phase: 'Phase 2',
    features: ['Report export', 'Live sync', 'Bulk edit', 'Templates'],
  ),

  // === Storage ===
  Integration(
    id: 'gdrive',
    name: 'Google Drive',
    category: IntegrationCategory.storage,
    tagline: 'Centralize creative assets',
    color: Color(0xFF1A73E8),
    phase: 'Phase 3',
    features: ['Asset sync', 'Folder permissions', 'Sharing', 'Version history'],
  ),
  Integration(
    id: 'dropbox',
    name: 'Dropbox',
    category: IntegrationCategory.storage,
    tagline: 'Brand asset library + replays',
    color: Color(0xFF0061FF),
    phase: 'Phase 3',
    features: ['Asset sync', 'Replay collaboration', 'Capture', 'Sign'],
  ),

  // === AI providers ===
  Integration(
    id: 'pollinations',
    name: 'Pollinations.ai',
    category: IntegrationCategory.ai,
    tagline: 'Free AI text + image (no key required)',
    color: Color(0xFF8B5CF6),
    status: IntegrationStatus.connected,
    phase: 'Now',
    features: ['Text generation', 'Image generation', 'No API key', 'No rate limits for demo'],
  ),
  Integration(
    id: 'anthropic',
    name: 'Anthropic (Claude)',
    category: IntegrationCategory.ai,
    tagline: 'Best-in-class long-form copy + chat',
    color: Color(0xFFD97757),
    phase: 'Phase 3',
    features: ['Claude Opus + Sonnet', 'Vision', 'Tool use', '200k context'],
  ),
  Integration(
    id: 'openai',
    name: 'OpenAI',
    category: IntegrationCategory.ai,
    tagline: 'GPT-4o, DALL-E, Whisper',
    color: Color(0xFF10A37F),
    phase: 'Phase 3',
    features: ['GPT-4o', 'DALL-E 3', 'Whisper STT', 'Embeddings'],
  ),
  Integration(
    id: 'gemini',
    name: 'Google Gemini',
    category: IntegrationCategory.ai,
    tagline: 'Multimodal AI with Workspace integration',
    color: Color(0xFFFBBC04),
    phase: 'Phase 3',
    features: ['Gemini Pro/Ultra', '2M context', 'Workspace sync', 'Vision'],
  ),
];
