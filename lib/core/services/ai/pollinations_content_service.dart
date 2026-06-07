import 'dart:async';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'content_generation_service.dart';

/// Pollinations.ai — FREE text generation, NO key, NO signup, NO card.
///
/// Uses the OpenAI-compatible POST endpoint at https://text.pollinations.ai/openai
/// which is more reliable than the GET-with-embedded-prompt URL form (avoids
/// URL-length limits and the 403s that came with the May 2025 referrer policy).
/// Falls through to mock if the network is unavailable.
class PollinationsContentService implements ContentGenerationService {
  PollinationsContentService({Dio? client})
      : _dio = client ??
            Dio(BaseOptions(
              baseUrl: 'https://text.pollinations.ai',
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 60),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                // Pollinations now requires a referrer identifier to allowlist callers.
                'Referer': 'https://mythrix.ai',
              },
            ));

  final Dio _dio;
  final Logger _log = Logger();

  // Pollinations free-tier models that don't require a token.
  static const _model = 'openai';

  @override
  String get displayName => 'Pollinations.ai (free, no key)';

  @override
  ProviderStatus get status => ProviderStatus.ready;

  @override
  Stream<GenerationChunk> generate(ContentBrief brief) async* {
    for (var i = 0; i < brief.variants; i++) {
      yield* _streamOne(brief, i);
    }
  }

  Stream<GenerationChunk> _streamOne(ContentBrief brief, int variantIndex) async* {
    final systemPrompt = brief.systemPrompt();
    final userPrompt =
        'Variant ${variantIndex + 1} of ${brief.variants}.\n\nBrief:\n${brief.prompt}';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/openai',
        data: {
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'stream': false,
          'referrer': 'mythrix',
        },
        queryParameters: {'referrer': 'mythrix'},
      );

      final text = _extractContent(response.data) ?? '';

      // Simulate streaming: chunk by words so the UI feels alive.
      final words = text.split(' ');
      for (final w in words) {
        await Future<void>.delayed(const Duration(milliseconds: 12));
        yield GenerationChunk('$w ', variantIndex: variantIndex);
      }

      yield GenerationChunk('', variantIndex: variantIndex, isFinal: true);
    } on DioException catch (e) {
      _log.w('Pollinations text failed: ${e.message} — letting router fall back.');
      rethrow;
    }
  }

  /// Single-shot text completion used by non-streaming callers (chat).
  Future<String> oneShot(String prompt) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/openai',
        data: {
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'referrer': 'mythrix',
        },
        queryParameters: {'referrer': 'mythrix'},
      );
      return _extractContent(response.data) ?? '';
    } catch (e) {
      _log.w('Pollinations oneShot failed: $e');
      return '';
    }
  }

  /// Pull the text out of an OpenAI-compatible chat completion response.
  String? _extractContent(Map<String, dynamic>? data) {
    if (data == null) return null;
    final choices = data['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      if (first is Map) {
        final msg = first['message'];
        if (msg is Map && msg['content'] is String) {
          return msg['content'] as String;
        }
        // Some responses use `text` directly.
        if (first['text'] is String) return first['text'] as String;
      }
    }
    // Fall back: if the API returned a raw string in `response` or `output`.
    if (data['response'] is String) return data['response'] as String;
    if (data['output'] is String) return data['output'] as String;
    return null;
  }
}
