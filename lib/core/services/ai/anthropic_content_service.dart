import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import 'content_generation_service.dart';

/// Anthropic Claude implementation of ContentGenerationService.
///
/// Hits the official Messages API at https://api.anthropic.com/v1/messages
/// with the streaming flag enabled, parsing server-sent events.
class AnthropicContentService implements ContentGenerationService {
  AnthropicContentService({
    this.model = 'claude-sonnet-4-6',
    Dio? client,
  }) : _dio = client ??
            Dio(BaseOptions(
              baseUrl: 'https://api.anthropic.com/v1',
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 60),
              responseType: ResponseType.stream,
            ));

  final String model;
  final Dio _dio;
  final Logger _log = Logger();

  String? get _key {
    final k = dotenv.maybeGet('ANTHROPIC_API_KEY');
    return (k == null || k.isEmpty) ? null : k;
  }

  @override
  String get displayName => 'Anthropic Claude ($model)';

  @override
  ProviderStatus get status =>
      _key == null ? ProviderStatus.missingKey : ProviderStatus.ready;

  @override
  Stream<GenerationChunk> generate(ContentBrief brief) async* {
    if (status != ProviderStatus.ready) {
      throw StateError(
          'ANTHROPIC_API_KEY missing. Add it to .env to use Claude.');
    }

    for (var i = 0; i < brief.variants; i++) {
      yield* _streamOne(brief, i);
    }
  }

  Stream<GenerationChunk> _streamOne(ContentBrief brief, int variantIndex) async* {
    final body = {
      'model': model,
      'max_tokens': brief.maxTokens,
      'system': brief.systemPrompt(),
      'stream': true,
      'messages': [
        {
          'role': 'user',
          'content':
              'Variant ${variantIndex + 1} of ${brief.variants}. Brief:\n\n${brief.prompt}',
        }
      ],
    };

    try {
      final response = await _dio.post<ResponseBody>(
        '/messages',
        data: body,
        options: Options(
          headers: {
            'x-api-key': _key,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
            'accept': 'text/event-stream',
          },
        ),
      );

      final stream = response.data!.stream
          .map((b) => utf8.decode(b))
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (!line.startsWith('data:')) continue;
        final payload = line.substring(5).trim();
        if (payload.isEmpty || payload == '[DONE]') continue;

        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          if (json['type'] == 'content_block_delta') {
            final delta = json['delta'] as Map<String, dynamic>?;
            final text = delta?['text'] as String?;
            if (text != null && text.isNotEmpty) {
              yield GenerationChunk(text, variantIndex: variantIndex);
            }
          }
        } catch (_) {
          // Ignore malformed event chunks.
        }
      }

      yield GenerationChunk('', variantIndex: variantIndex, isFinal: true);
    } on DioException catch (e) {
      _log.e('Anthropic API error', error: e);
      rethrow;
    }
  }
}
