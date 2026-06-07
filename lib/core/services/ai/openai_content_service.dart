import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:openai_dart/openai_dart.dart';

import 'content_generation_service.dart';

/// OpenAI implementation using the maintained `openai_dart` package.
class OpenAiContentService implements ContentGenerationService {
  OpenAiContentService({this.model = 'gpt-4o'});

  final String model;
  final Logger _log = Logger();

  String? get _key {
    final k = dotenv.maybeGet('OPENAI_API_KEY');
    return (k == null || k.isEmpty) ? null : k;
  }

  OpenAIClient? _client;
  OpenAIClient? get _ensureClient {
    final key = _key;
    if (key == null) return null;
    _client ??= OpenAIClient(apiKey: key);
    return _client;
  }

  @override
  String get displayName => 'OpenAI ($model)';

  @override
  ProviderStatus get status =>
      _key == null ? ProviderStatus.missingKey : ProviderStatus.ready;

  @override
  Stream<GenerationChunk> generate(ContentBrief brief) async* {
    final client = _ensureClient;
    if (client == null) {
      throw StateError('OPENAI_API_KEY missing. Add it to .env to use OpenAI.');
    }

    for (var i = 0; i < brief.variants; i++) {
      yield* _streamOne(client, brief, i);
    }
  }

  Stream<GenerationChunk> _streamOne(
    OpenAIClient client,
    ContentBrief brief,
    int variantIndex,
  ) async* {
    try {
      final stream = client.createChatCompletionStream(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(model),
          maxTokens: brief.maxTokens,
          messages: [
            ChatCompletionMessage.system(content: brief.systemPrompt()),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(
                'Variant ${variantIndex + 1} of ${brief.variants}. Brief:\n\n${brief.prompt}',
              ),
            ),
          ],
        ),
      );

      await for (final res in stream) {
        final delta = res.choices.firstOrNull?.delta.content;
        if (delta != null && delta.isNotEmpty) {
          yield GenerationChunk(delta, variantIndex: variantIndex);
        }
      }

      yield GenerationChunk('', variantIndex: variantIndex, isFinal: true);
    } catch (e, s) {
      _log.e('OpenAI API error', error: e, stackTrace: s);
      rethrow;
    }
  }
}

extension on List<ChatCompletionStreamResponseChoice> {
  ChatCompletionStreamResponseChoice? get firstOrNull =>
      isEmpty ? null : first;
}
