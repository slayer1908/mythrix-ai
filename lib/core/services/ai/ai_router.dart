import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'anthropic_content_service.dart';
import 'content_generation_service.dart';
import 'gemini_content_service.dart';
import 'mock_content_service.dart';
import 'openai_content_service.dart';
import 'pollinations_content_service.dart';

/// Selects which underlying provider handles a generation request.
///
/// Priority (top to bottom):
///   1. The provider named in `AI_DEFAULT_TEXT_PROVIDER` (if its key is set)
///   2. Gemini (free tier, requires key)
///   3. Anthropic Claude (paid, requires key)
///   4. OpenAI (paid, requires key)
///   5. Pollinations.ai (FREE, no key required) — always works online
///   6. Mock (always works offline)
class AiRouter implements ContentGenerationService {
  AiRouter({
    GeminiContentService? gemini,
    AnthropicContentService? anthropic,
    OpenAiContentService? openai,
    PollinationsContentService? pollinations,
    MockContentService? mock,
  })  : _gemini = gemini ?? GeminiContentService(),
        _anthropic = anthropic ?? AnthropicContentService(),
        _openai = openai ?? OpenAiContentService(),
        _pollinations = pollinations ?? PollinationsContentService(),
        _mock = mock ?? MockContentService();

  final GeminiContentService _gemini;
  final AnthropicContentService _anthropic;
  final OpenAiContentService _openai;
  final PollinationsContentService _pollinations;
  final MockContentService _mock;

  ContentGenerationService get active {
    final pref =
        (dotenv.maybeGet('AI_DEFAULT_TEXT_PROVIDER') ?? 'pollinations').toLowerCase();

    // Honor explicit preference if its key is configured.
    if (pref == 'gemini' && _gemini.status == ProviderStatus.ready) return _gemini;
    if (pref == 'anthropic' && _anthropic.status == ProviderStatus.ready) return _anthropic;
    if (pref == 'openai' && _openai.status == ProviderStatus.ready) return _openai;
    if (pref == 'pollinations') return _pollinations;
    if (pref == 'mock') return _mock;

    // Fallback chain: prefer real providers with keys, then free Pollinations.
    if (_gemini.status == ProviderStatus.ready) return _gemini;
    if (_anthropic.status == ProviderStatus.ready) return _anthropic;
    if (_openai.status == ProviderStatus.ready) return _openai;
    return _pollinations; // Always ready, free, no key needed.
  }

  /// True if any real (non-mock) provider is reachable.
  /// Pollinations counts as a real provider — it returns real AI output.
  bool get hasRealProvider =>
      _gemini.status == ProviderStatus.ready ||
      _anthropic.status == ProviderStatus.ready ||
      _openai.status == ProviderStatus.ready ||
      _pollinations.status == ProviderStatus.ready;

  @override
  String get displayName => active.displayName;

  @override
  ProviderStatus get status => active.status;

  @override
  Stream<GenerationChunk> generate(ContentBrief brief) => active.generate(brief);
}
