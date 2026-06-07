import 'dart:async';

import 'content_generation_service.dart';

/// Spec for image generation requests.
class ImageBrief {
  const ImageBrief({
    required this.prompt,
    this.aspect = '1:1',
    this.style = '',
    this.count = 4,
    this.seed,
  });

  final String prompt;
  final String aspect; // '1:1', '4:5', '9:16', '16:9', '3:2'
  final String style;
  final int count;
  final int? seed;

  String get composedPrompt {
    final styleSuffix = style.isEmpty ? '' : ', $style, high quality, detailed';
    return '$prompt$styleSuffix';
  }

  /// Returns (width, height) for the requested aspect ratio.
  (int, int) get dimensions {
    return switch (aspect) {
      '1:1' => (1024, 1024),
      '4:5' => (1024, 1280),
      '9:16' => (720, 1280),
      '16:9' => (1280, 720),
      '3:2' => (1280, 854),
      _ => (1024, 1024),
    };
  }
}

/// Each generated image is just a URL the UI loads via CachedNetworkImage.
class GeneratedImage {
  const GeneratedImage({required this.url, required this.seed, this.label});
  final String url;
  final int seed;
  final String? label;
}

abstract class ImageGenerationService {
  String get displayName;
  ProviderStatus get status;

  /// Generate `brief.count` images. Returns a list of public image URLs.
  /// Each URL is cacheable and renderable as-is.
  Future<List<GeneratedImage>> generate(ImageBrief brief);
}
