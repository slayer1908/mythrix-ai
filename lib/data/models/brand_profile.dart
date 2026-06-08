import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Whether the user is running a single brand or managing many for clients.
enum AccountType { brand, agency }

extension AccountTypeX on AccountType {
  String get label {
    switch (this) {
      case AccountType.brand: return 'I run a brand / business';
      case AccountType.agency: return 'I run an agency / freelance';
    }
  }

  String get description {
    switch (this) {
      case AccountType.brand:
        return 'Single brand workspace. Mythrix learns your voice + audience and runs your marketing.';
      case AccountType.agency:
        return 'Multi-client workspace. Set up the agency once, then add a brand for each client.';
    }
  }

  IconData get icon {
    switch (this) {
      case AccountType.brand: return Icons.storefront_rounded;
      case AccountType.agency: return Icons.workspaces_rounded;
    }
  }
}

/// User's brand profile — captured during onboarding, feeds every AI prompt.
class BrandProfile {
  const BrandProfile({
    this.id = '',
    required this.brandName,
    required this.accentColor,
    required this.voiceTags,
    required this.audience,
    required this.primaryGoal,
    required this.industry,
    this.accountType = AccountType.brand,
  });

  final String id;
  final String brandName;
  final Color accentColor;
  final List<String> voiceTags;
  final String audience;
  final String primaryGoal;
  final String industry;
  final AccountType accountType;

  /// Used by [ContentBrief.systemPrompt] to inject brand context into the LLM.
  String toPromptContext() {
    return '''
Brand: $brandName
Industry: $industry
Voice: ${voiceTags.join(", ")}
Target audience: $audience
Primary goal: $primaryGoal
''';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'brandName': brandName,
        'accentColorValue': accentColor.toARGB32(),
        'voiceTags': voiceTags,
        'audience': audience,
        'primaryGoal': primaryGoal,
        'industry': industry,
        'accountType': accountType.name,
      };

  static BrandProfile fromMap(Map<dynamic, dynamic> m) => BrandProfile(
        id: m['id'] as String? ?? '',
        brandName: m['brandName'] as String? ?? 'Your Brand',
        accentColor: Color((m['accentColorValue'] as num?)?.toInt() ??
            AppColors.mythrixViolet.toARGB32()),
        voiceTags: (m['voiceTags'] as List?)?.cast<String>() ?? const [],
        audience: m['audience'] as String? ?? '',
        primaryGoal: m['primaryGoal'] as String? ?? '',
        industry: m['industry'] as String? ?? '',
        accountType: AccountType.values.firstWhere(
          (t) => t.name == m['accountType'],
          orElse: () => AccountType.brand,
        ),
      );

  static const _builderDefaults = BrandProfile(
    brandName: '',
    accentColor: AppColors.mythrixViolet,
    voiceTags: [],
    audience: '',
    primaryGoal: '',
    industry: '',
  );

  /// Empty profile, used while the user is filling out the wizard.
  static BrandProfile empty() => _builderDefaults;

  bool get isComplete =>
      brandName.isNotEmpty &&
      voiceTags.isNotEmpty &&
      (accountType == AccountType.agency || audience.isNotEmpty) &&
      (accountType == AccountType.agency || primaryGoal.isNotEmpty);

  BrandProfile copyWith({
    String? id,
    String? brandName,
    Color? accentColor,
    List<String>? voiceTags,
    String? audience,
    String? primaryGoal,
    String? industry,
    AccountType? accountType,
  }) {
    return BrandProfile(
      id: id ?? this.id,
      brandName: brandName ?? this.brandName,
      accentColor: accentColor ?? this.accentColor,
      voiceTags: voiceTags ?? this.voiceTags,
      audience: audience ?? this.audience,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      industry: industry ?? this.industry,
      accountType: accountType ?? this.accountType,
    );
  }
}

/// "Vibes" — brand colors with mood labels people understand without
/// knowing color theory. Each maps to a Mythrix design-system swatch.
class BrandVibe {
  const BrandVibe(this.label, this.tagline, this.color);
  final String label;
  final String tagline;
  final Color color;
}

const kBrandVibes = <BrandVibe>[
  BrandVibe('Bold', 'Confident, energetic, attention-grabbing', AppColors.mythrixViolet),
  BrandVibe('Trusted', 'Professional, dependable, blue-chip', AppColors.mythrixIndigo),
  BrandVibe('Playful', 'Fun, friendly, conversational', AppColors.mythrixPink),
  BrandVibe('Premium', 'Luxurious, exclusive, refined', AppColors.mythrixMagenta),
  BrandVibe('Calm', 'Clean, balanced, considered', AppColors.mythrixCyan),
  BrandVibe('Energetic', 'Fresh, alive, optimistic', AppColors.mythrixLime),
  BrandVibe('Warm', 'Inviting, human, approachable', AppColors.mythrixAmber),
  BrandVibe('Bold + warm', 'Loud, hot, viral', AppColors.mythrixCoral),
];

/// Legacy alias — kept for any code still reading raw colors.
const kBrandColorPresets = <Color>[
  AppColors.mythrixViolet,
  AppColors.mythrixCyan,
  AppColors.mythrixMagenta,
  AppColors.mythrixLime,
  AppColors.mythrixAmber,
  AppColors.mythrixCoral,
  AppColors.mythrixIndigo,
  AppColors.mythrixPink,
];

const kVoiceTagOptions = <String>[
  'Confident', 'Friendly', 'Witty', 'Bold', 'Calm', 'Authoritative',
  'Playful', 'Luxury', 'Tech-savvy', 'Empathetic', 'Direct', 'Inspiring',
  'Conversational', 'Edgy', 'Premium', 'Approachable',
];

const kIndustryOptions = <String>[
  'SaaS / Software', 'E-commerce', 'D2C / Retail', 'Agency', 'Creator / Influencer',
  'Healthcare', 'Finance', 'Education', 'Real Estate', 'Hospitality',
  'B2B Services', 'Non-profit', 'Other',
];

const kGoalOptions = <String>[
  'Drive sales',
  'Generate leads',
  'Build brand awareness',
  'Grow social following',
  'Launch a new product',
  'Re-engage customers',
];
