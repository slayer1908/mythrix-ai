import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

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
  });

  final String id;
  final String brandName;
  final Color accentColor;
  final List<String> voiceTags;
  final String audience;
  final String primaryGoal;
  final String industry;

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
      audience.isNotEmpty &&
      primaryGoal.isNotEmpty;

  BrandProfile copyWith({
    String? id,
    String? brandName,
    Color? accentColor,
    List<String>? voiceTags,
    String? audience,
    String? primaryGoal,
    String? industry,
  }) {
    return BrandProfile(
      id: id ?? this.id,
      brandName: brandName ?? this.brandName,
      accentColor: accentColor ?? this.accentColor,
      voiceTags: voiceTags ?? this.voiceTags,
      audience: audience ?? this.audience,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      industry: industry ?? this.industry,
    );
  }
}

/// Picker presets shown in the wizard.
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
