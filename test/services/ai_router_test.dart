import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mythrix_ai/core/services/ai/ai_router.dart';
import 'package:mythrix_ai/core/services/ai/content_generation_service.dart';
import 'package:mythrix_ai/core/services/ai/mock_content_service.dart';
import 'package:mythrix_ai/data/models/content_draft.dart';

void main() {
  group('AiRouter', () {
    setUp(() async {
      // Ensure dotenv has no real keys for these tests.
      dotenv.testLoad(fileInput: '');
    });

    test('falls back to mock when no API keys present', () {
      final router = AiRouter();
      expect(router.hasRealProvider, isFalse);
      expect(router.active, isA<MockContentService>());
      expect(router.status, ProviderStatus.ready);
    });

    test('mock provider streams a finite, ordered set of variants', () async {
      final router = AiRouter();
      final brief = ContentBrief(
        type: ContentType.socialPost,
        tone: ContentTone.friendly,
        prompt: 'Test prompt',
        variants: 2,
      );

      final received = <int>[];
      var finals = 0;

      await for (final chunk in router.generate(brief)) {
        if (chunk.isFinal) {
          finals++;
        } else {
          if (received.isEmpty || received.last != chunk.variantIndex) {
            received.add(chunk.variantIndex);
          }
        }
      }

      expect(finals, 2);
      expect(received, [0, 1]);
    });
  });
}
