import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'nav_destinations.dart';

/// Spotlight-style command palette. Opens with Cmd/Ctrl+K. Lists navigation
/// destinations + common quick actions; live-filters as you type.
class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  int _selected = 0;

  List<_PaletteEntry> get _all => [
        for (final s in kNavSections)
          for (final d in s.destinations)
            _PaletteEntry(
              icon: d.icon,
              label: 'Go to ${d.label}',
              hint: s.title,
              action: () => context.go(d.route),
            ),
        _PaletteEntry(
          icon: Icons.auto_awesome_rounded,
          label: 'Generate ad copy for a new campaign',
          hint: 'AI action',
          action: () => context.go('/app/content'),
        ),
        _PaletteEntry(
          icon: Icons.bolt_rounded,
          label: 'Trigger MYTHRIX auto-optimize',
          hint: 'Automations',
          action: () {},
        ),
        _PaletteEntry(
          icon: Icons.add_chart_rounded,
          label: 'New campaign — Google Ads',
          hint: 'Ads',
          action: () => context.go('/app/ads'),
        ),
        _PaletteEntry(
          icon: Icons.publish_rounded,
          label: 'Schedule a post across all channels',
          hint: 'Scheduler',
          action: () => context.go('/app/social'),
        ),
      ];

  List<_PaletteEntry> get _filtered {
    final q = _ctrl.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all
        .where((e) =>
            e.label.toLowerCase().contains(q) || e.hint.toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _exec(_PaletteEntry e) {
    Navigator.of(context).pop();
    e.action();
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final items = _filtered;
    if (items.isEmpty) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _selected = (_selected + 1) % items.length);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() => _selected = (_selected - 1 + items.length) % items.length);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.enter) {
      _exec(items[_selected]);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    if (_selected >= items.length) _selected = 0;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 48,
                    offset: const Offset(0, 24),
                  ),
                ],
              ),
              child: Focus(
                onKeyEvent: _handleKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        onChanged: (_) => setState(() => _selected = 0),
                        decoration: const InputDecoration(
                          hintText: 'Type a command, search, or ask MYTHRIX…',
                          prefixIcon: Icon(Icons.search_rounded),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 380),
                      child: items.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(AppSpacing.xxl),
                              child: Text('No matches'),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                              itemCount: items.length,
                              itemBuilder: (_, i) {
                                final e = items[i];
                                final active = i == _selected;
                                return InkWell(
                                  onTap: () => _exec(e),
                                  onHover: (h) {
                                    if (h) setState(() => _selected = i);
                                  },
                                  child: Container(
                                    color: active
                                        ? AppColors.mythrixViolet.withValues(alpha: 0.12)
                                        : null,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          e.icon,
                                          size: 18,
                                          color: active
                                              ? AppColors.mythrixViolet
                                              : Theme.of(context).colorScheme.onSurface
                                                  .withValues(alpha: 0.7),
                                        ),
                                        AppSpacing.hGapSm,
                                        Expanded(
                                          child: Text(
                                            e.label,
                                            style: TextStyle(
                                              fontWeight: active
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          e.hint,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface
                                                .withValues(alpha: 0.5),
                                            fontSize: 11,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          _Kbd('↑ ↓'),
                          AppSpacing.hGapXs,
                          Text('to navigate',
                              style: Theme.of(context).textTheme.labelSmall),
                          AppSpacing.hGapMd,
                          _Kbd('↵'),
                          AppSpacing.hGapXs,
                          Text('to select',
                              style: Theme.of(context).textTheme.labelSmall),
                          AppSpacing.hGapMd,
                          _Kbd('Esc'),
                          AppSpacing.hGapXs,
                          Text('to close',
                              style: Theme.of(context).textTheme.labelSmall),
                          const Spacer(),
                          const _AiBadge(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaletteEntry {
  _PaletteEntry({
    required this.icon,
    required this.label,
    required this.hint,
    required this.action,
  });
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback action;
}

class _Kbd extends StatelessWidget {
  const _Kbd(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Text(text,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 10)),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 11),
          SizedBox(width: 4),
          Text('Ask MYTHRIX',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3)),
        ],
      ),
    );
  }
}
