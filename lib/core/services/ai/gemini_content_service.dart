import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import 'content_generation_service.dart';

/// Google Gemini implementation — uses the FREE-tier Gemini API.
///
/// Free tier (as of 2026):
///   • Gemini 1.5 Flash — 1,500 requests/day, 1M tokens/min
///   • No credit card required
///   • Get a key in 60 seconds at https://aistudio.google.com/apikey
///
/// Hits `streamGenerateContent` to get token-by-token streaming.
class GeminiContentService implements ContentGenerationService {
  GeminiContentService({
    this.model = 'gemini-1.5-flash',
    Dio? client,
  }) : _dio = client ??
            Dio(BaseOptions(
              baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 60),
              responseType: ResponseType.stream,
            ));

  final String model;
  final Dio _dio;
  final Logger _log = Logger();

  String? get _key {
    final k = dotenv.maybeGet('GEMINI_API_KEY');
    return (k == null || k.isEmpty) ? null : k;
  }

  @override
  String get displayName => 'Google Gemini ($model · free)';

  @override
  ProviderStatus get status =>
      _key == null ? ProviderStatus.missingKey : ProviderStatus.ready;

  @override
  Stream<GenerationChunk> generate(ContentBrief brief) async* {
    if (status != ProviderStatus.ready) {
      throw StateError(
        'GEMINI_API_KEY missing. Get one free (no card) at '
        'https://aistudio.google.com/apikey and add to .env.',
      );
    }

    for (var i = 0; i < brief.variants; i++) {
      yield* _streamOne(brief, i);
    }
  }

  Stream<GenerationChunk> _streamOne(ContentBrief brief, int variantIndex) async* {
    final body = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text':
                  '${brief.systemPrompt()}\n\nVariant ${variantIndex + 1} of ${brief.variants}.\n\nBrief:\n${brief.prompt}',
            }
          ],
        }
      ],
      'generationConfig': {
        'maxOutputTokens': brief.maxTokens,
        'temperature': 0.8,
      },
    };

    try {
      final response = await _dio.post<ResponseBody>(
        '/models/$model:streamGenerateContent',
        queryParameters: {'alt': 'sse', 'key': _key},
        data: body,
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
          final candidates = json['candidates'] as List<dynamic>?;
          final parts = (candidates?.first as Map<String, dynamic>?)?['content']
              as Map<String, dynamic>?;
          final textParts = parts?['parts'] as List<dynamic>?;
          final text = textParts?.first['text'] as String?;
          if (text != null && text.isNotEmpty) {
            yield GenerationChunk(text, variantIndex: variantIndex);
          }
        } catch (_) {
          // Ignore malformed event chunks.
        }
      }

      yield GenerationChunk('', variantIndex: variantIndex, isFinal: true);
    } on DioException catch (e) {
      _log.e('Gemini API error', error: e);
      rethrow;
    }
  }
}
