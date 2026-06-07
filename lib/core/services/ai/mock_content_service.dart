import 'dart:async';

import '../../../data/models/content_draft.dart';
import 'content_generation_service.dart';

/// Fallback service used when no API key is configured.
///
/// Generates plausible-looking template content with simulated streaming
/// latency, so the UI behaves identically to production even offline.
class MockContentService implements ContentGenerationService {
  @override
  String get displayName => 'Mock (no API key)';

  @override
  ProviderStatus get status => ProviderStatus.ready;

  @override
  Stream<GenerationChunk> generate(ContentBrief brief) async* {
    for (var i = 0; i < brief.variants; i++) {
      yield* _streamVariant(brief, i);
    }
  }

  Stream<GenerationChunk> _streamVariant(ContentBrief brief, int v) async* {
    final body = _template(brief, v);
    final words = body.split(' ');
    for (final w in words) {
      await Future<void>.delayed(const Duration(milliseconds: 18));
      yield GenerationChunk('$w ', variantIndex: v);
    }
    yield GenerationChunk('', variantIndex: v, isFinal: true);
  }

  String _template(ContentBrief b, int v) {
    final toneAdj = switch (b.tone) {
      ContentTone.professional => 'measured, expert',
      ContentTone.friendly => 'warm, approachable',
      ContentTone.witty => 'sharp, playful',
      ContentTone.urgent => 'high-stakes, decisive',
      ContentTone.inspiring => 'bold, energizing',
      ContentTone.authoritative => 'commanding, exact',
      ContentTone.conversational => 'natural, breezy',
      ContentTone.luxury => 'refined, exclusive',
    };

    return switch (b.type) {
      ContentType.socialPost =>
        'V${v + 1} · social · $toneAdj\n\n${_hook(b.prompt, v)}\n\n${_para(b.prompt)}\n\n${_cta(v)}\n\n#mythrix #ai #growth',
      ContentType.adCopy =>
        'Headline: ${_headline(b.prompt, v)}\nDescription: ${_para(b.prompt)}\nCTA: ${_cta(v)}',
      ContentType.blogPost =>
        '# ${_headline(b.prompt, v)}\n\n## TL;DR\n${_para(b.prompt)}\n\n## Why it matters\n${_para(b.prompt)}\n\n## The 3-step playbook\n1. Diagnose the gap\n2. Generate variations\n3. Measure & re-allocate',
      ContentType.email =>
        'Subject: ${_headline(b.prompt, v)}\nPreview: ${_para(b.prompt).substring(0, 60)}...\n\nHi {{first_name}},\n\n${_para(b.prompt)}\n\n${_cta(v)}\n\n— Mythrix',
      ContentType.productDescription =>
        '${_headline(b.prompt, v)}\n\n${_para(b.prompt)}\n\nKey benefits:\n• Always-on AI optimization\n• Cross-channel orchestration\n• Brand-safe creative generation',
      ContentType.landingPage =>
        'H1: ${_headline(b.prompt, v)}\nSub: ${_para(b.prompt)}\n\nFEATURE 1 — Autopilot ads.\nFEATURE 2 — Creative on demand.\nFEATURE 3 — Live ROAS.',
      ContentType.videoScript =>
        '[0:00] Hook — ${_hook(b.prompt, v)}\n[0:08] Insight — ${_para(b.prompt)}\n[0:24] Proof — show 3 results.\n[0:36] CTA — ${_cta(v)}',
      ContentType.smsText =>
        '${_hook(b.prompt, v)} → ${_cta(v)} (Reply STOP to opt out)',
    };
  }

  String _hook(String p, int v) => switch (v) {
        0 => 'What if every dollar spent earned five back? With Mythrix, that\'s tonight.',
        1 => 'Most teams ship campaigns. Mythrix ships outcomes.',
        _ => 'The era of manual marketing is ending. Here\'s what comes next.',
      };

  String _headline(String p, int v) => switch (v) {
        0 => 'Marketing on autopilot — your numbers will prove it',
        1 => 'Win the channel. Win the customer. Sleep at night.',
        _ => 'You don\'t need more tools. You need one brain.',
      };

  String _cta(int v) => switch (v) {
        0 => 'Start free — no card required',
        1 => 'See Mythrix run your stack in 90 seconds',
        _ => 'Book a private demo with our growth team',
      };

  String _para(String p) =>
      'Based on the brief, Mythrix highlights $p, leaning into proof points, social validation, and a single call-to-action that reduces friction to one tap.';
}
