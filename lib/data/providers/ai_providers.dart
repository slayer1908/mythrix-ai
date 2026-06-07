import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/ai/ai_router.dart';
import '../../core/services/ai/content_generation_service.dart';
import '../../core/services/ai/image_generation_service.dart';
import '../../core/services/ai/pollinations_image_service.dart';

/// Singleton AiRouter for the app (text generation).
final aiRouterProvider = Provider<AiRouter>((_) => AiRouter());

/// Convenience — exposes the active provider's status (live vs mock).
final aiStatusProvider = Provider<ProviderStatus>(
  (ref) => ref.watch(aiRouterProvider).status,
);

/// True when at least one real LLM provider is reachable.
final hasLiveAiProvider = Provider<bool>(
  (ref) => ref.watch(aiRouterProvider).hasRealProvider,
);

/// Image generation service — Pollinations by default (free, no key).
final imageServiceProvider = Provider<ImageGenerationService>(
  (_) => PollinationsImageService(),
);
