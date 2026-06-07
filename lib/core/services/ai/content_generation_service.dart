import 'dart:async';

import '../../../data/models/brand_profile.dart';
import '../../../data/models/content_draft.dart';

/// Brief that drives content generation.
class ContentBrief {
  const ContentBrief({
    required this.type,
    required this.tone,
    required this.prompt,
    this.brandVoice = '',
    this.audience = '',
    this.language = 'en',
    this.variants = 3,
    this.maxTokens = 1200,
    this.profile,
  });

  final ContentType type;
  final ContentTone tone;
  final String prompt;
  final String brandVoice;
  final String audience;
  final String language;
  final int variants;
  final int maxTokens;

  /// Brand profile captured during onboarding. Injected into systemPrompt()
  /// so every generation is personalized to the user's brand.
  final BrandProfile? profile;

  /// Builds the system prompt sent to the LLM.
  String systemPrompt() {
    final brand = profile?.toPromptContext() ?? '';
    final voiceFallback = profile?.voiceTags.join(', ') ?? '';
    final audienceFallback = profile?.audience ?? '';

    return '''
You are MYTHRIX, an elite autonomous marketing AI. You generate on-brand
${type.displayName.toLowerCase()} content tailored for digital marketing.

${brand.isEmpty ? '' : '--- BRAND CONTEXT ---\n$brand--------------------\n'}
Tone: ${tone.displayName}.
Brand voice guidelines: ${brandVoice.isEmpty ? (voiceFallback.isEmpty ? 'professional, modern, results-driven' : voiceFallback) : brandVoice}.
Target audience: ${audience.isEmpty ? (audienceFallback.isEmpty ? 'general consumers' : audienceFallback) : audience}.
Language: $language.

Rules:
- Be concise, scannable, and high-impact.
- Lead with a strong hook.
- Use active voice and concrete numbers when possible.
- Avoid corporate clichés ("game-changer", "synergy", "leverage", "best-in-class").
- End with one clear call-to-action.
- For social posts include 3-5 relevant hashtags.
- For ad copy provide headline, description, and CTA on separate lines.
- For email content include Subject, Preview text, then the body.

Produce ONE complete variant per request.
''';
  }
}

/// A streamable result from a content generation request.
class GenerationChunk {
  const GenerationChunk(this.text, {this.variantIndex = 0, this.isFinal = false});
  final String text;
  final int variantIndex;
  final bool isFinal;
}

/// Status of an AI provider.
enum ProviderStatus { ready, missingKey, error }

/// Abstract interface every concrete provider implements.
///
/// The router picks one based on availability and the user's preference.
abstract class ContentGenerationService {
  /// Human-readable name (e.g. "Anthropic Claude").
  String get displayName;

  /// Tells the app whether to actually call this provider.
  ProviderStatus get status;

  /// Generate `brief.variants` variants. Each variant streams back as
  /// successive GenerationChunks with the same variantIndex, terminated by
  /// `isFinal: true`.
  Stream<GenerationChunk> generate(ContentBrief brief);
}
