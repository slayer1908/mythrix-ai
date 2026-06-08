import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aurora_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/brand_profile.dart';
import '../../data/providers/brand_profile_providers.dart';

/// 4-step branded onboarding wizard.
///
/// Captures brand name + color, voice tags, audience, and primary goal.
/// Saves to Hive via [brandProfileProvider]. After completion the router
/// stops sending the user here and they go straight to the dashboard.
class OnboardingWizard extends ConsumerStatefulWidget {
  const OnboardingWizard({super.key});

  @override
  ConsumerState<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends ConsumerState<OnboardingWizard> {
  final _pageCtrl = PageController();
  int _step = 0;

  // Field state
  AccountType? _accountType;
  final _brandNameCtrl = TextEditingController();
  final _audienceCtrl = TextEditingController();
  Color _accent = AppColors.mythrixViolet;
  String _vibeLabel = 'Bold';
  final Set<String> _voiceTags = {};
  String _industry = 'SaaS / Software';
  String _goal = '';

  /// Step count: Brand → 6 steps (Type, Name, Vibe, Voice, Audience, Goal+Celebration combined)
  /// Agency → 4 steps (Type, Name, Vibe, Celebration)
  int get _totalSteps =>
      _accountType == AccountType.agency ? 4 : 6;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _brandNameCtrl.dispose();
    _audienceCtrl.dispose();
    super.dispose();
  }

  bool get _canContinue {
    // Step 0 = account type
    if (_step == 0) return _accountType != null;

    // Brand vs Agency path (different step indices)
    if (_accountType == AccountType.agency) {
      switch (_step) {
        case 1: return _brandNameCtrl.text.trim().isNotEmpty; // Agency name
        case 2: return true; // Vibe (preselected)
        case 3: return true; // Celebration
      }
    } else {
      switch (_step) {
        case 1: return _brandNameCtrl.text.trim().isNotEmpty; // Brand name
        case 2: return true; // Vibe (preselected)
        case 3: return _voiceTags.isNotEmpty;
        case 4: return _audienceCtrl.text.trim().isNotEmpty;
        case 5: return _goal.isNotEmpty; // Goal + celebration combined
      }
    }
    return false;
  }

  void _next() {
    if (!_canContinue) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageCtrl.animateToPage(
        _step,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _prev() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageCtrl.animateToPage(
      _step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    final isAgency = _accountType == AccountType.agency;
    final profile = BrandProfile(
      brandName: _brandNameCtrl.text.trim(),
      accentColor: _accent,
      voiceTags: isAgency ? const ['Professional'] : _voiceTags.toList(),
      audience: isAgency
          ? 'Multiple client audiences'
          : _audienceCtrl.text.trim(),
      primaryGoal: isAgency
          ? 'Manage clients'
          : _goal,
      industry: isAgency ? 'Agency' : _industry,
      accountType: _accountType ?? AccountType.brand,
    );
    ref.read(brandProfileProvider.notifier).save(profile);
    context.go(AppRoutes.dashboard);
  }

  /// Skip → save a minimal placeholder profile so the router lets the user
  /// through to the dashboard. They can fill in real details later via Brand
  /// Assets. Without this, the router redirects them back to onboarding
  /// because `onboardingDoneProvider` would still be false.
  List<Widget> _buildSteps() {
    // Step 0 is always Account Type
    final base = <Widget>[
      _StepAccountType(
        selected: _accountType,
        onSelect: (t) => setState(() => _accountType = t),
      ),
    ];

    if (_accountType == AccountType.agency) {
      return [
        ...base,
        _StepName(
          ctrl: _brandNameCtrl,
          title: "What's your agency called?",
          subtitle: 'This is the workspace name. You\'ll add a brand profile per client later.',
          industry: 'Agency',
          showIndustry: false,
          onIndustry: (_) {},
          onNameChanged: () => setState(() {}),
        ),
        _StepVibe(
          selected: _vibeLabel,
          onSelect: (v) => setState(() {
            _vibeLabel = v.label;
            _accent = v.color;
          }),
        ),
        _Step4Celebration(
          brandName: _brandNameCtrl.text.trim().isNotEmpty ? _brandNameCtrl.text : 'My agency',
          accent: _accent,
          voiceTags: const ['Professional'],
          audience: 'Multiple client audiences',
          goal: 'Manage clients',
          industry: 'Agency',
        ),
      ];
    }

    // Brand path
    return [
      ...base,
      _StepName(
        ctrl: _brandNameCtrl,
        title: "What's your brand called?",
        subtitle: 'This is what customers know you as. We\'ll use it in every AI prompt and document.',
        industry: _industry,
        showIndustry: true,
        onIndustry: (s) => setState(() => _industry = s),
        onNameChanged: () => setState(() {}),
      ),
      _StepVibe(
        selected: _vibeLabel,
        onSelect: (v) => setState(() {
          _vibeLabel = v.label;
          _accent = v.color;
        }),
      ),
      _Step1Voice(
        selected: _voiceTags,
        onToggle: (t) => setState(() {
          if (_voiceTags.contains(t)) {
            _voiceTags.remove(t);
          } else {
            if (_voiceTags.length < 5) _voiceTags.add(t);
          }
        }),
      ),
      _Step2Audience(
        ctrl: _audienceCtrl,
        onChanged: () => setState(() {}),
      ),
      _Step3Goal(
        selected: _goal,
        onSelect: (g) => setState(() => _goal = g),
      ),
    ];
  }

  void _skip() {
    final type = _accountType ?? AccountType.brand;
    final placeholder = BrandProfile(
      brandName: _brandNameCtrl.text.trim().isNotEmpty
          ? _brandNameCtrl.text.trim()
          : (type == AccountType.agency ? 'My agency' : 'My brand'),
      accentColor: _accent,
      voiceTags: _voiceTags.isNotEmpty ? _voiceTags.toList() : ['Friendly'],
      audience: _audienceCtrl.text.trim().isNotEmpty
          ? _audienceCtrl.text.trim()
          : (type == AccountType.agency ? 'Multiple client audiences' : 'My audience'),
      primaryGoal: _goal.isNotEmpty
          ? _goal
          : (type == AccountType.agency ? 'Manage clients' : 'Build brand awareness'),
      industry: type == AccountType.agency ? 'Agency' : (_industry.isNotEmpty ? _industry : 'Other'),
      accountType: type,
    );
    ref.read(brandProfileProvider.notifier).save(placeholder);
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProgressBar(step: _step, total: _totalSteps),
                      AppSpacing.vGapXl,
                      SizedBox(
                        height: 420,
                        child: PageView(
                          controller: _pageCtrl,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (i) => setState(() => _step = i),
                          children: _buildSteps(),
                        ),
                      ),
                      AppSpacing.vGapLg,
                      Row(
                        children: [
                          if (_step > 0)
                            TextButton.icon(
                              onPressed: _prev,
                              icon: const Icon(Icons.arrow_back_rounded, size: 16),
                              label: const Text('Back'),
                            ),
                          const Spacer(),
                          TextButton(
                            onPressed: _skip,
                            child: const Text('Skip for now'),
                          ),
                          AppSpacing.hGapSm,
                          GradientButton(
                            label: _step == _totalSteps - 1
                                ? 'Enter Mythrix'
                                : (_step == _totalSteps - 2 ? 'Preview' : 'Continue'),
                            icon: _step == _totalSteps - 1
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            onPressed: _canContinue ? _next : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= step
                    ? AppColors.mythrixViolet
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i != total - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

// ---------- Step 0 — Brand basics ----------

class _Step0Brand extends StatelessWidget {
  const _Step0Brand({
    required this.nameCtrl,
    required this.accent,
    required this.industry,
    required this.onAccent,
    required this.onIndustry,
    required this.onNameChanged,
  });
  final TextEditingController nameCtrl;
  final Color accent;
  final String industry;
  final ValueChanged<Color> onAccent;
  final ValueChanged<String> onIndustry;
  final VoidCallback onNameChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's set up your brand 👋",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        AppSpacing.vGapXs,
        Text(
          "MYTHRIX will use this to personalize every piece of content it generates.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        AppSpacing.vGapLg,
        TextField(
          controller: nameCtrl,
          onChanged: (_) => onNameChanged(),
          decoration: const InputDecoration(
            labelText: 'Brand name',
            hintText: 'e.g. Brewline, Acme Co., Stellar Studios',
            prefixIcon: Icon(Icons.brush_rounded),
          ),
        ),
        AppSpacing.vGapMd,
        Text('Industry', style: Theme.of(context).textTheme.labelMedium),
        AppSpacing.vGapXs,
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kIndustryOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final v = kIndustryOptions[i];
              return ChoiceChip(
                label: Text(v, style: const TextStyle(fontSize: 12)),
                selected: industry == v,
                onSelected: (_) => onIndustry(v),
              );
            },
          ),
        ),
        AppSpacing.vGapMd,
        Text('Brand accent color', style: Theme.of(context).textTheme.labelMedium),
        AppSpacing.vGapXs,
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final c in kBrandColorPresets)
              GestureDetector(
                onTap: () => onAccent(c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c == accent ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: c == accent
                        ? [
                            BoxShadow(
                              color: c.withValues(alpha: 0.5),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------- Step 1 — Voice tags ----------

class _Step1Voice extends StatelessWidget {
  const _Step1Voice({required this.selected, required this.onToggle});
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How should MYTHRIX sound?",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        AppSpacing.vGapXs,
        Text(
          "Pick up to 5 tone descriptors. We'll use these in every generated piece.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        AppSpacing.vGapLg,
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: AppSpacing.xs + 2,
              runSpacing: AppSpacing.xs + 2,
              children: [
                for (final t in kVoiceTagOptions)
                  FilterChip(
                    label: Text(t),
                    selected: selected.contains(t),
                    onSelected: (_) => onToggle(t),
                    selectedColor: AppColors.mythrixViolet.withValues(alpha: 0.25),
                    checkmarkColor: Colors.white,
                  ),
              ],
            ),
          ),
        ),
        AppSpacing.vGapSm,
        Text(
          '${selected.length} / 5 selected',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
        ),
      ],
    );
  }
}

// ---------- Step 2 — Audience ----------

class _Step2Audience extends StatelessWidget {
  const _Step2Audience({required this.ctrl, required this.onChanged});
  final TextEditingController ctrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Who are you trying to reach?",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        AppSpacing.vGapXs,
        Text(
          "Describe your ideal customer. Be specific — better targeting = better output.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        AppSpacing.vGapLg,
        TextField(
          controller: ctrl,
          onChanged: (_) => onChanged(),
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Target audience',
            hintText:
                'e.g. Heads of marketing at \$10-100M DTC brands, mostly US-based, frustrated with disconnected tools.',
            alignLabelWithHint: true,
          ),
        ),
        AppSpacing.vGapMd,
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.mythrixCyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.mythrixCyan.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  color: AppColors.mythrixCyan, size: 16),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  'Tip: include role, company size, region, and a pain point.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------- Step 3 — Goal ----------

class _Step3Goal extends StatelessWidget {
  const _Step3Goal({required this.selected, required this.onSelect});
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What's the #1 marketing goal?",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        AppSpacing.vGapXs,
        Text(
          "Pick the one outcome that matters most this quarter.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        AppSpacing.vGapLg,
        Expanded(
          child: ListView(
            children: [
              for (final g in kGoalOptions)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _GoalTile(
                    label: g,
                    selected: selected == g,
                    onTap: () => onSelect(g),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.mythrixViolet.withValues(alpha: 0.18)
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected
                ? AppColors.mythrixViolet
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected
                  ? AppColors.mythrixViolet
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 22,
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Step 4 — Celebration / preview ----------

class _Step4Celebration extends StatefulWidget {
  const _Step4Celebration({
    required this.brandName,
    required this.accent,
    required this.voiceTags,
    required this.audience,
    required this.goal,
    required this.industry,
  });

  final String brandName;
  final Color accent;
  final List<String> voiceTags;
  final String audience;
  final String goal;
  final String industry;

  @override
  State<_Step4Celebration> createState() => _Step4CelebrationState();
}

class _Step4CelebrationState extends State<_Step4Celebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScaleTransition(
          scale: Tween(begin: 0.85, end: 1.0).animate(
            CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0, 0.5, curve: Curves.easeOutBack)),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0, 0.4, curve: Curves.easeOut)),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      widget.accent,
                      widget.accent.withValues(alpha: 0.6),
                    ]),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: -4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.brandName.isEmpty
                        ? '?'
                        : widget.brandName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.brandName,
                        style: Theme.of(context).textTheme.headlineSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.industry,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSpacing.vGapMd,
        FadeTransition(
          opacity: CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.25, 0.6, curve: Curves.easeOut)),
          child: Text(
            "You're all set, ${widget.brandName.isEmpty ? "" : "${widget.brandName} "}team. 🎉",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        AppSpacing.vGapXs,
        FadeTransition(
          opacity: CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
          child: Text(
            'Every piece of content, image, and campaign Mythrix generates will be calibrated to your brand from now on.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
          ),
        ),
        AppSpacing.vGapMd,
        FadeTransition(
          opacity: CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.45, 0.85, curve: Curves.easeOut)),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniRow(
                  label: 'Voice',
                  value: widget.voiceTags.isEmpty
                      ? '(none)'
                      : widget.voiceTags.join(' · '),
                ),
                AppSpacing.vGapXs,
                _MiniRow(label: 'Goal', value: widget.goal),
                AppSpacing.vGapXs,
                _MiniRow(
                    label: 'Audience',
                    value: widget.audience.length > 90
                        ? '${widget.audience.substring(0, 90)}…'
                        : widget.audience),
              ],
            ),
          ),
        ),
        AppSpacing.vGapMd,
        FadeTransition(
          opacity: CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                widget.accent.withValues(alpha: 0.18),
                AppColors.mythrixCyan.withValues(alpha: 0.12),
              ]),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: widget.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.rocket_launch_rounded, color: widget.accent, size: 16),
                AppSpacing.hGapSm,
                Expanded(
                  child: Text(
                    'Mythrix is ready. Click "Enter Mythrix" to launch your mission control.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.8,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

// ===== NEW: Account type picker (Step 0) =====

class _StepAccountType extends StatelessWidget {
  const _StepAccountType({required this.selected, required this.onSelect});
  final AccountType? selected;
  final ValueChanged<AccountType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("First — who's signing up?",
            style: Theme.of(context).textTheme.headlineSmall),
        AppSpacing.vGapXs,
        Text(
          'Mythrix tailors itself to how you work. Pick the one that fits.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        AppSpacing.vGapLg,
        for (final t in AccountType.values) ...[
          _AccountTypeCard(
            type: t,
            selected: selected == t,
            onTap: () => onSelect(t),
          ),
          AppSpacing.vGapSm,
        ],
      ],
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });
  final AccountType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: selected
                ? LinearGradient(colors: [
                    AppColors.mythrixViolet.withValues(alpha: 0.15),
                    AppColors.mythrixCyan.withValues(alpha: 0.08),
                  ])
                : null,
            border: Border.all(
              color: selected ? AppColors.mythrixViolet : color.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.mythrixViolet.withValues(alpha: 0.18)
                      : color.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(type.icon,
                    color: selected ? AppColors.mythrixViolet : null),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    AppSpacing.vGapXs,
                    Text(
                      type.description,
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: color.onSurface.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle_rounded,
                      color: AppColors.mythrixViolet),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== NEW: Name + Industry (replaces _Step0Brand) =====

class _StepName extends StatelessWidget {
  const _StepName({
    required this.ctrl,
    required this.title,
    required this.subtitle,
    required this.industry,
    required this.showIndustry,
    required this.onIndustry,
    required this.onNameChanged,
  });

  final TextEditingController ctrl;
  final String title, subtitle, industry;
  final bool showIndustry;
  final ValueChanged<String> onIndustry;
  final VoidCallback onNameChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        AppSpacing.vGapXs,
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        AppSpacing.vGapLg,
        TextField(
          controller: ctrl,
          onChanged: (_) => onNameChanged(),
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Brewline, Acme Co., Stellar Studios',
            prefixIcon: Icon(Icons.brush_rounded),
          ),
        ),
        if (showIndustry) ...[
          AppSpacing.vGapMd,
          Text('Industry', style: Theme.of(context).textTheme.labelMedium),
          AppSpacing.vGapXs,
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kIndustryOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final v = kIndustryOptions[i];
                return ChoiceChip(
                  label: Text(v, style: const TextStyle(fontSize: 12)),
                  selected: industry == v,
                  onSelected: (_) => onIndustry(v),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// ===== NEW: Vibe picker =====

class _StepVibe extends StatelessWidget {
  const _StepVibe({required this.selected, required this.onSelect});
  final String selected;
  final ValueChanged<BrandVibe> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Pick a vibe', style: Theme.of(context).textTheme.headlineSmall),
        AppSpacing.vGapXs,
        Text(
          "Don't overthink it — Mythrix uses this for accent colors across the app. Change it anytime in Brand Assets.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        AppSpacing.vGapLg,
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: kBrandVibes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.0,
            ),
            itemBuilder: (_, i) => _VibeCard(
              vibe: kBrandVibes[i],
              selected: selected == kBrandVibes[i].label,
              onTap: () => onSelect(kBrandVibes[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _VibeCard extends StatelessWidget {
  const _VibeCard({
    required this.vibe,
    required this.selected,
    required this.onTap,
  });
  final BrandVibe vibe;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: selected
                ? LinearGradient(colors: [
                    vibe.color.withValues(alpha: 0.18),
                    vibe.color.withValues(alpha: 0.04),
                  ])
                : null,
            border: Border.all(
              color: selected ? vibe.color : Theme.of(context).colorScheme.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: vibe.color,
                  shape: BoxShape.circle,
                  boxShadow: selected
                      ? [BoxShadow(color: vibe.color.withValues(alpha: 0.5), blurRadius: 10)]
                      : null,
                ),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vibe.label,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(
                      vibe.tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
