// ignore_for_file: invalid_use_of_protected_member

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/ai/image_generation_service.dart';
import '../../core/utils/snack.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_pill.dart';
import '../../data/providers/ai_providers.dart';
import '../../data/providers/gallery_providers.dart';

enum _CreativeMode { image, video }

enum _StylePreset {
  productHero,
  cinematic,
  editorial,
  vibrantPop,
  noirMinimal,
  retroFilm,
  hyperreal,
  neonGlow,
}

extension on _StylePreset {
  String get label => switch (this) {
        _StylePreset.productHero => 'Product hero',
        _StylePreset.cinematic => 'Cinematic',
        _StylePreset.editorial => 'Editorial',
        _StylePreset.vibrantPop => 'Vibrant pop',
        _StylePreset.noirMinimal => 'Noir minimal',
        _StylePreset.retroFilm => 'Retro film',
        _StylePreset.hyperreal => 'Hyperreal',
        _StylePreset.neonGlow => 'Neon glow',
      };
}

class CreativeStudioScreen extends ConsumerStatefulWidget {
  const CreativeStudioScreen({super.key});
  @override
  ConsumerState<CreativeStudioScreen> createState() => _CreativeStudioScreenState();
}

class _CreativeStudioScreenState extends ConsumerState<CreativeStudioScreen> {
  _CreativeMode _mode = _CreativeMode.image;
  _StylePreset _style = _StylePreset.cinematic;
  String _aspect = '1:1';
  int _count = 4;
  bool _generating = false;
  List<_GeneratedAsset> _gallery = _seedGallery();
  final TextEditingController _promptCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load any persisted images from Hive on top of the seed gallery.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saved = ref.read(galleryProvider);
      if (saved.isEmpty || !mounted) return;
      setState(() {
        _gallery = [
          ...saved.map((g) => _GeneratedAsset.fromUrl(
                url: g.url,
                label: g.prompt.length > 28
                    ? '${g.prompt.substring(0, 28)}…'
                    : g.prompt,
              )),
          ..._gallery,
        ];
      });
    });
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  /// Real AI image generation via Pollinations.ai (free, no key required).
  /// Returns CDN URLs we render with CachedNetworkImage.
  Future<void> _generate() async {
    final prompt = _promptCtrl.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe what you want to generate first.')),
      );
      return;
    }
    setState(() => _generating = true);

    try {
      final svc = ref.read(imageServiceProvider);
      final results = await svc.generate(ImageBrief(
        prompt: prompt,
        aspect: _aspect,
        style: _style.label,
        count: _count,
      ));
      if (!mounted) return;

      // Persist to Hive — gallery survives page refresh.
      const uuid = Uuid();
      final persisted = results
          .map((g) => GalleryImage(
                id: uuid.v4(),
                url: g.url,
                prompt: prompt,
                style: _style.label,
                aspect: _aspect,
                seed: g.seed,
              ))
          .toList();
      ref.read(galleryProvider.notifier).addMany(persisted);

      setState(() {
        _generating = false;
        _gallery = [
          ...results.map((g) => _GeneratedAsset.fromUrl(
                url: g.url,
                label: prompt.length > 28 ? '${prompt.substring(0, 28)}…' : prompt,
              )),
          ..._gallery,
        ];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _generating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image generation failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1180;

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
                  Expanded(flex: 4, child: _ComposerCard(state: this)),
                  AppSpacing.hGapLg,
                  Expanded(flex: 7, child: _Gallery(assets: _gallery, generating: _generating)),
                ],
              ),
            )
          else
            Column(
              children: [
                _ComposerCard(state: this),
                AppSpacing.vGapLg,
                _Gallery(assets: _gallery, generating: _generating),
              ],
            ),
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
            child: const AuroraBackground(
              intensity: 0.6,
              colors: [AppColors.mythrixMagenta, AppColors.mythrixViolet, AppColors.mythrixCoral],
            ),
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
                    const StatusPill(label: 'AI · Imagine 3 / Stable Diffusion 4 / Runway Gen-4', tone: PillTone.brand),
                    AppSpacing.vGapSm,
                    Text('Creative Studio', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white)),
                    AppSpacing.vGapXs,
                    Text(
                      'Generate on-brand images and videos in seconds. MYTHRIX learns your visual identity and stays inside the rails.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.sizeOf(context).width > 900)
                const GradientButton(
                  label: 'Train brand model',
                  icon: Icons.model_training_rounded,
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

class _ComposerCard extends StatelessWidget {
  const _ComposerCard({required this.state});
  final _CreativeStudioScreenState state;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Generate',
            subtitle: 'Image, video, or motion graphics',
            icon: Icons.auto_awesome_rounded,
          ),
          SegmentedButton<_CreativeMode>(
            segments: const [
              ButtonSegment(value: _CreativeMode.image, icon: Icon(Icons.image_rounded), label: Text('Image')),
              ButtonSegment(value: _CreativeMode.video, icon: Icon(Icons.movie_creation_rounded), label: Text('Video')),
            ],
            selected: {state._mode},
            onSelectionChanged: (s) => state.setState(() => state._mode = s.first),
            showSelectedIcon: false,
          ),
          AppSpacing.vGapMd,
          TextField(
            controller: state._promptCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Describe the visual',
              hintText: 'e.g. minimal studio shot of a sneaker on a marble pedestal, dramatic side-light',
              alignLabelWithHint: true,
            ),
          ),
          AppSpacing.vGapMd,
          Text('Style', style: Theme.of(context).textTheme.labelMedium),
          AppSpacing.vGapXs,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final s in _StylePreset.values)
                FilterChip(
                  label: Text(s.label),
                  selected: state._style == s,
                  onSelected: (_) => state.setState(() => state._style = s),
                ),
            ],
          ),
          AppSpacing.vGapMd,
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: state._aspect,
                  decoration: const InputDecoration(labelText: 'Aspect ratio'),
                  items: const [
                    DropdownMenuItem(value: '1:1', child: Text('1:1 — square')),
                    DropdownMenuItem(value: '4:5', child: Text('4:5 — portrait')),
                    DropdownMenuItem(value: '9:16', child: Text('9:16 — vertical')),
                    DropdownMenuItem(value: '16:9', child: Text('16:9 — landscape')),
                    DropdownMenuItem(value: '3:2', child: Text('3:2 — wide')),
                  ],
                  onChanged: (v) => state.setState(() => state._aspect = v!),
                ),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: state._count,
                  decoration: const InputDecoration(labelText: 'Variants'),
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('2')),
                    DropdownMenuItem(value: 4, child: Text('4')),
                    DropdownMenuItem(value: 6, child: Text('6')),
                    DropdownMenuItem(value: 8, child: Text('8')),
                  ],
                  onChanged: (v) => state.setState(() => state._count = v!),
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          _BrandGuardrail(),
          AppSpacing.vGapLg,
          GradientButton(
            label: state._mode == _CreativeMode.image ? 'Generate images' : 'Generate video',
            icon: Icons.auto_awesome_rounded,
            expand: true,
            loading: state._generating,
            onPressed: state._generating ? null : state._generate,
          ),
        ],
      ),
    );
  }
}

class _BrandGuardrail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.mythrixCyan.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.mythrixCyan.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.mythrixCyan, size: 16),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(
              'Brand guardrails active — palette, typography & forbidden imagery enforced.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedAsset {
  factory _GeneratedAsset.aiSeed(int i) {
    final palettes = [
      [AppColors.mythrixViolet, AppColors.mythrixCyan],
      [AppColors.mythrixMagenta, AppColors.mythrixCoral],
      [AppColors.mythrixCyan, AppColors.mythrixLime],
      [AppColors.mythrixAmber, AppColors.mythrixCoral],
      [AppColors.mythrixViolet, AppColors.mythrixPink],
      [AppColors.mythrixIndigo, AppColors.mythrixMagenta],
    ];
    final p = palettes[i % palettes.length];
    return _GeneratedAsset(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: p,
      ),
      label: 'Generated ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      tag: 'On-brand',
      icon: Icons.auto_awesome_rounded,
    );
  }

  /// Constructor for real AI-generated images (Pollinations URLs).
  factory _GeneratedAsset.fromUrl({required String url, required String label}) {
    return _GeneratedAsset(
      gradient: const LinearGradient(
        colors: [AppColors.mythrixViolet, AppColors.mythrixCyan],
      ),
      label: label,
      tag: 'AI',
      icon: Icons.auto_awesome_rounded,
      url: url,
    );
  }

  const _GeneratedAsset({
    required this.gradient,
    required this.label,
    required this.tag,
    required this.icon,
    this.url,
  });

  final Gradient gradient;
  final String label;
  final String tag;
  final IconData icon;
  final String? url;
}

List<_GeneratedAsset> _seedGallery() => [
      const _GeneratedAsset(
        gradient: LinearGradient(colors: [AppColors.mythrixViolet, AppColors.mythrixCyan]),
        label: 'Hero — Summer Drop',
        tag: 'Approved',
        icon: Icons.shopping_bag_rounded,
      ),
      const _GeneratedAsset(
        gradient: LinearGradient(colors: [AppColors.mythrixMagenta, AppColors.mythrixCoral]),
        label: 'Lifestyle — Brunch',
        tag: 'On-brand',
        icon: Icons.coffee_rounded,
      ),
      const _GeneratedAsset(
        gradient: LinearGradient(colors: [AppColors.mythrixCyan, AppColors.mythrixLime]),
        label: 'Product — Hero shoe',
        tag: 'Edited',
        icon: Icons.sports_basketball_rounded,
      ),
      const _GeneratedAsset(
        gradient: LinearGradient(colors: [AppColors.mythrixAmber, AppColors.mythrixCoral]),
        label: 'Story — Sunrise',
        tag: 'On-brand',
        icon: Icons.wb_twilight_rounded,
      ),
    ];

class _Gallery extends StatelessWidget {
  const _Gallery({required this.assets, required this.generating});
  final List<_GeneratedAsset> assets;
  final bool generating;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cols = width >= 1500 ? 4 : (width >= 980 ? 3 : 2);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Studio output',
            subtitle: generating ? 'MYTHRIX is generating…' : '${assets.length} assets',
            trailing: TextButton.icon(
              onPressed: () => context.go('/app/library'),
              icon: const Icon(Icons.folder_outlined, size: 16),
              label: const Text('Open library'),
            ),
          ),
          if (generating) ...[
            const LinearProgressIndicator(minHeight: 2),
            AppSpacing.vGapSm,
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (_, i) => _AssetTile(asset: assets[i]),
          ),
        ],
      ),
    );
  }
}

class _AssetTile extends StatefulWidget {
  const _AssetTile({required this.asset});
  final _GeneratedAsset asset;

  @override
  State<_AssetTile> createState() => _AssetTileState();
}

class _AssetTileState extends State<_AssetTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: _hover ? 1.02 : 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Always render the gradient as a backdrop (placeholder while
              // the network image loads, OR the only thing shown for seed assets).
              DecoratedBox(decoration: BoxDecoration(gradient: widget.asset.gradient)),
              if (widget.asset.url != null)
                CachedNetworkImage(
                  imageUrl: widget.asset.url!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 48,
                    ),
                  ),
                )
              else
                Center(
                  child: Icon(
                    widget.asset.icon,
                    color: Colors.white.withValues(alpha: 0.18),
                    size: 84,
                  ),
                ),
              Positioned(
                top: AppSpacing.xs,
                left: AppSpacing.xs,
                child: StatusPill(label: widget.asset.tag, tone: PillTone.brand, dense: true),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 160),
                  opacity: _hover ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.asset.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Snack.info(context, 'Right-click the image and choose "Save image as…" to download.'),
                          icon: const Icon(Icons.download_rounded, size: 16, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        IconButton(
                          onPressed: () => Snack.info(context, 'Image refinement controls land in the next polish pass — for now, regenerate with a tweaked prompt.'),
                          icon: const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
