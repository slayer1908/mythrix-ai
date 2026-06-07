import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/ai/content_generation_service.dart';
import '../../core/services/ai/image_generation_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/models/content_draft.dart';
import '../../core/utils/snack.dart';
import '../../data/providers/ai_providers.dart';
import '../../data/providers/brand_profile_providers.dart';
import '../../data/providers/gallery_providers.dart';
import 'widgets/draft_history.dart';
import 'widgets/prompt_composer.dart';
import 'widgets/template_grid.dart';

class ContentStudioScreen extends ConsumerStatefulWidget {
  const ContentStudioScreen({super.key});
  @override
  ConsumerState<ContentStudioScreen> createState() => _ContentStudioScreenState();
}

class _ContentStudioScreenState extends ConsumerState<ContentStudioScreen> {
  ContentType _type = ContentType.socialPost;
  ContentTone _tone = ContentTone.friendly;
  String _brand = '';
  String _audience = '';
  String _prompt = '';
  bool _generating = false;
  bool _generatingImage = false;
  List<String> _outputs = [];
  int _activeOutput = 0;
  String? _coverImageUrl;

  StreamSubscription<GenerationChunk>? _genSub;

  @override
  void dispose() {
    _genSub?.cancel();
    super.dispose();
  }

  /// Streaming generation against the live AI router.
  /// Falls back to a mock provider automatically when no API key is present —
  /// see [AiRouter].
  Future<void> _generate() async {
    if (_prompt.trim().isEmpty) return;
    await _genSub?.cancel();

    setState(() {
      _generating = true;
      _outputs = List.filled(3, '');
      _activeOutput = 0;
      _coverImageUrl = null;
    });

    final profile = ref.read(brandProfileProvider);
    final brief = ContentBrief(
      type: _type,
      tone: _tone,
      prompt: _prompt,
      brandVoice: _brand,
      audience: _audience,
      variants: 3,
      profile: profile,
    );

    final router = ref.read(aiRouterProvider);

    try {
      _genSub = router.generate(brief).listen(
        (chunk) {
          if (!mounted) return;
          if (chunk.isFinal) return;
          setState(() {
            _outputs[chunk.variantIndex] += chunk.text;
            if (_activeOutput == 0 && chunk.variantIndex == 0 && _outputs[0].isEmpty) {
              // keep activeOutput tracking the first non-empty variant
            }
          });
        },
        onError: (Object e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Generation failed: $e')),
          );
          setState(() => _generating = false);
        },
        onDone: () {
          if (!mounted) return;
          setState(() => _generating = false);
          // Auto-save every non-empty variant to the drafts library.
          final drafts = ref.read(draftsStoreProvider.notifier);
          for (var i = 0; i < _outputs.length; i++) {
            final body = _outputs[i].trim();
            if (body.isEmpty) continue;
            final firstLine = body.split('\n').first;
            final title = firstLine.length > 60
                ? '${firstLine.substring(0, 60)}…'
                : firstLine;
            drafts.add(
              title: title,
              body: body,
              type: _type.name,
              tone: _tone.name,
            );
          }
          // Fire matching cover image in parallel — doesn't block UX.
          _generateCoverImage();
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start generation: $e')),
      );
      setState(() => _generating = false);
    }
  }

  /// Generates ONE matching cover image for the current prompt and saves it
  /// to the gallery. Runs after text gen completes — non-blocking.
  Future<void> _generateCoverImage() async {
    if (!mounted || _prompt.trim().isEmpty) return;
    setState(() => _generatingImage = true);

    try {
      final svc = ref.read(imageServiceProvider);
      final results = await svc.generate(ImageBrief(
        prompt: _prompt,
        aspect: _type == ContentType.socialPost ? '4:5' : '16:9',
        style: 'editorial, vibrant',
        count: 1,
      ));

      if (results.isEmpty || !mounted) return;
      final url = results.first.url;

      // Persist to gallery too.
      const uuid = Uuid();
      ref.read(galleryProvider.notifier).addMany([
        GalleryImage(
          id: uuid.v4(),
          url: url,
          prompt: _prompt,
          style: 'editorial, vibrant',
          aspect: _type == ContentType.socialPost ? '4:5' : '16:9',
          seed: results.first.seed,
        ),
      ]);

      setState(() {
        _coverImageUrl = url;
        _generatingImage = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _generatingImage = false);
    }
  }

  // ---- Legacy template helpers (kept for fallback / offline preview only) ----
  // ignore: unused_element
  List<String> _simulate(String prompt, ContentType type, ContentTone tone) {
    return [for (var i = 0; i < 3; i++) _template(type, tone, prompt, i)];
  }

  String _template(ContentType type, ContentTone tone, String prompt, int variant) {
    final toneAdj = switch (tone) {
      ContentTone.professional => 'measured, expert',
      ContentTone.friendly => 'warm, approachable',
      ContentTone.witty => 'sharp, playful',
      ContentTone.urgent => 'high-stakes, decisive',
      ContentTone.inspiring => 'bold, energizing',
      ContentTone.authoritative => 'commanding, exact',
      ContentTone.conversational => 'natural, breezy',
      ContentTone.luxury => 'refined, exclusive',
    };

    final blocks = switch (type) {
      ContentType.socialPost => [
          'V$variant · social post · $toneAdj\n\n${_hookFor(prompt, variant)}\n\n${_paragraph(prompt)}\n\n${_ctaFor(variant)}\n\n#AI #Growth #MYTHRIX',
        ],
      ContentType.adCopy => [
          'Headline ${variant + 1}: ${_headlineFor(prompt, variant)}\nDescription: ${_paragraph(prompt)}\nCTA: ${_ctaFor(variant)}',
        ],
      ContentType.blogPost => [
          '# ${_headlineFor(prompt, variant)}\n\n## TL;DR\n${_paragraph(prompt)}\n\n## Why it matters\n${_paragraph(prompt)}\n\n## The 3-step playbook\n1. Diagnose the gap\n2. Generate variations\n3. Measure & re-allocate',
        ],
      ContentType.email => [
          'Subject: ${_headlineFor(prompt, variant)}\nPreview: ${_paragraph(prompt).substring(0, 80)}...\n\nHey {{first_name}},\n\n${_paragraph(prompt)}\n\n${_ctaFor(variant)}\n\n— The MYTHRIX team',
        ],
      ContentType.productDescription => [
          '${_headlineFor(prompt, variant)}\n\n${_paragraph(prompt)}\n\nKey benefits:\n• Always-on AI optimization\n• Cross-channel orchestration\n• Brand-safe creative generation',
        ],
      ContentType.landingPage => [
          'H1: ${_headlineFor(prompt, variant)}\nSub: ${_paragraph(prompt)}\n\nFEATURE 1 — Autopilot ads.\nFEATURE 2 — Creative on demand.\nFEATURE 3 — Live ROAS.',
        ],
      ContentType.videoScript => [
          '[0:00] Hook — ${_hookFor(prompt, variant)}\n[0:08] Insight — ${_paragraph(prompt)}\n[0:24] Proof — show 3 results.\n[0:36] CTA — ${_ctaFor(variant)}',
        ],
      ContentType.smsText => [
          '${_hookFor(prompt, variant)} → ${_ctaFor(variant)} (Reply STOP to opt out)',
        ],
    };
    return blocks.first;
  }

  String _hookFor(String p, int v) => switch (v) {
        0 => 'What if every dollar spent earned five back? With MYTHRIX, that\'s tonight.',
        1 => 'Most teams ship campaigns. MYTHRIX ships *outcomes*.',
        _ => 'The era of manual marketing is ending. Here\'s what comes next.',
      };

  String _headlineFor(String p, int v) => switch (v) {
        0 => 'Marketing on autopilot — and your numbers prove it',
        1 => 'Win the channel. Win the customer. Sleep at night.',
        _ => 'You don\'t need more tools. You need one brain.',
      };

  String _ctaFor(int v) => switch (v) {
        0 => 'Start free — no card required',
        1 => 'See MYTHRIX run your stack in 90 seconds',
        _ => 'Book a private demo with our growth team',
      };

  String _paragraph(String p) =>
      'Based on the brief, MYTHRIX would highlight $p, leaning into proof points, social validation, and a single call-to-action that reduces friction to one tap.';

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 1180;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Hero(),
          AppSpacing.vGapXl,
          if (wide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: _Composer(
                      type: _type,
                      tone: _tone,
                      brand: _brand,
                      audience: _audience,
                      onType: (t) => setState(() => _type = t),
                      onTone: (t) => setState(() => _tone = t),
                      onBrand: (s) => _brand = s,
                      onAudience: (s) => _audience = s,
                      onPrompt: (s) => _prompt = s,
                      onSubmit: _generate,
                      loading: _generating,
                    ),
                  ),
                  AppSpacing.hGapLg,
                  Expanded(
                    flex: 6,
                    child: _OutputPanel(
                      outputs: _outputs,
                      active: _activeOutput,
                      onSwitch: (i) => setState(() => _activeOutput = i),
                      generating: _generating,
                      coverImageUrl: _coverImageUrl,
                      generatingImage: _generatingImage,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                _Composer(
                  type: _type,
                  tone: _tone,
                  brand: _brand,
                  audience: _audience,
                  onType: (t) => setState(() => _type = t),
                  onTone: (t) => setState(() => _tone = t),
                  onBrand: (s) => _brand = s,
                  onAudience: (s) => _audience = s,
                  onPrompt: (s) => _prompt = s,
                  onSubmit: _generate,
                  loading: _generating,
                ),
                AppSpacing.vGapLg,
                _OutputPanel(
                  outputs: _outputs,
                  active: _activeOutput,
                  onSwitch: (i) => setState(() => _activeOutput = i),
                  generating: _generating,
                  coverImageUrl: _coverImageUrl,
                  generatingImage: _generatingImage,
                ),
              ],
            ),
          AppSpacing.vGapXl,
          const TemplateGrid(),
          AppSpacing.vGapXl,
          const DraftHistory(),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: const AuroraBackground(intensity: 0.4),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatusPill(
                      label: 'AI · GPT-5 / Claude 4.6 / Llama 4',
                      tone: PillTone.brand,
                    ),
                    AppSpacing.vGapSm,
                    Text(
                      'Content Studio',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
                    ),
                    AppSpacing.vGapXs,
                    Text(
                      'Tell MYTHRIX what you need. We generate 3 brand-aligned variants in seconds — ready to ship across every channel.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.sizeOf(context).width > 900)
                const GradientButton(
                  label: 'Voice clone',
                  icon: Icons.mic_rounded,
                  onPressed: _noop,
                ),
            ],
          ),
        ),
      ],
    );
  }

  static void _noop() {}
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.type,
    required this.tone,
    required this.brand,
    required this.audience,
    required this.onType,
    required this.onTone,
    required this.onBrand,
    required this.onAudience,
    required this.onPrompt,
    required this.onSubmit,
    required this.loading,
  });

  final ContentType type;
  final ContentTone tone;
  final String brand;
  final String audience;
  final ValueChanged<ContentType> onType;
  final ValueChanged<ContentTone> onTone;
  final ValueChanged<String> onBrand;
  final ValueChanged<String> onAudience;
  final ValueChanged<String> onPrompt;
  final VoidCallback onSubmit;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return PromptComposer(
      type: type,
      tone: tone,
      brand: brand,
      audience: audience,
      onType: onType,
      onTone: onTone,
      onBrand: onBrand,
      onAudience: onAudience,
      onPrompt: onPrompt,
      onSubmit: onSubmit,
      loading: loading,
    );
  }
}

class _OutputPanel extends StatelessWidget {
  const _OutputPanel({
    required this.outputs,
    required this.active,
    required this.onSwitch,
    required this.generating,
    this.coverImageUrl,
    this.generatingImage = false,
  });

  final List<String> outputs;
  final int active;
  final ValueChanged<int> onSwitch;
  final bool generating;
  final String? coverImageUrl;
  final bool generatingImage;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Output',
            subtitle: outputs.isEmpty ? 'MYTHRIX will generate 3 variants here' : 'Variant ${active + 1} of ${outputs.length}',
            trailing: outputs.isEmpty
                ? null
                : Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: outputs[active]));
                          if (context.mounted) Snack.success(context, 'Copied variant ${active + 1} to clipboard.');
                        },
                        icon: const Icon(Icons.content_copy_rounded, size: 14),
                        label: const Text('Copy'),
                      ),
                      AppSpacing.hGapSm,
                      GradientButton(
                        label: 'Save & schedule',
                        icon: Icons.event_rounded,
                        size: MythrixButtonSize.small,
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: outputs[active]));
                          if (context.mounted) {
                            Snack.success(context, 'Variant copied — opening Scheduler. Paste it into the composer.');
                            context.go('/app/social');
                          }
                        },
                      ),
                    ],
                  ),
          ),
          if (outputs.isEmpty && !generating)
            _emptyState(context)
          else if (generating)
            _generatingState(context)
          else ...[
            if (coverImageUrl != null || generatingImage) ...[
              _CoverImageCard(url: coverImageUrl, loading: generatingImage),
              AppSpacing.vGapSm,
            ],
            _activeOutputView(context),
          ],
          if (outputs.length > 1) ...[
            AppSpacing.vGapMd,
            Row(
              children: [
                for (var i = 0; i < outputs.length; i++) ...[
                  _VariantChip(
                    index: i,
                    active: i == active,
                    onTap: () => onSwitch(i),
                  ),
                  if (i != outputs.length - 1) AppSpacing.hGapXs,
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  static void _noop() {}

  Widget _activeOutputView(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: SelectableText(
        outputs[active],
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
      ),
    );
  }

  Widget _generatingState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          const LinearProgressIndicator(minHeight: 2),
          AppSpacing.vGapMd,
          Text(
            'MYTHRIX is generating 3 on-brand variants…',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.mythrixViolet.withValues(alpha: 0.2),
                  AppColors.mythrixCyan.withValues(alpha: 0.1),
                ]),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.mythrixViolet.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.mythrixViolet, size: 36),
            ),
            AppSpacing.vGapMd,
            Text(
              'Ready when you are.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppSpacing.vGapXs,
            Text(
              'Describe what you need. Be as terse or as detailed as you like — MYTHRIX fills the gaps.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverImageCard extends StatelessWidget {
  const _CoverImageCard({required this.url, required this.loading});
  final String? url;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.mythrixViolet, AppColors.mythrixCyan],
                ),
              ),
            ),
            if (url != null)
              CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox.shrink(),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            if (loading)
              Container(
                color: Colors.black.withValues(alpha: 0.4),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    AppSpacing.vGapSm,
                    Text(
                      'Generating matching cover image…',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + 2,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 10),
                    SizedBox(width: 4),
                    Text(
                      'AI cover',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantChip extends StatelessWidget {
  const _VariantChip({required this.index, required this.active, required this.onTap});
  final int index;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          gradient: active ? AppColors.brandGradient : null,
          color: active ? null : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: active
                ? Colors.transparent
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          'Variant ${index + 1}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
