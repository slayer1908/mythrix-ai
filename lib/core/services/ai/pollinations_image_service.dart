import 'dart:math';

import 'content_generation_service.dart';
import 'image_generation_service.dart';

/// Free, no-key AI image generation via Pollinations.ai.
///
/// Each image URL is deterministic from (prompt, width, height, seed) — so
/// the same call returns the same image. We pass `nologo=true` to strip the
/// watermark and `enhance=true` for prompt-rewriting on the server side.
class PollinationsImageService implements ImageGenerationService {
  PollinationsImageService();

  final Random _rng = Random();

  @override
  String get displayName => 'Pollinations.ai (free image gen)';

  @override
  ProviderStatus get status => ProviderStatus.ready;

  @override
  Future<List<GeneratedImage>> generate(ImageBrief brief) async {
    final (w, h) = brief.dimensions;
    final encoded = Uri.encodeComponent(brief.composedPrompt);

    return List.generate(brief.count, (i) {
      final seed = (brief.seed ?? _rng.nextInt(1 << 30)) + i * 7919;
      final url =
          'https://image.pollinations.ai/prompt/$encoded?width=$w&height=$h&seed=$seed&nologo=true&enhance=true&model=flux';
      return GeneratedImage(url: url, seed: seed);
    });
  }
}
