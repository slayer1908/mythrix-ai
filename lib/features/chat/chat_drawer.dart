import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../core/services/auto_week_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../data/models/chat_message.dart';
import '../../data/providers/ai_providers.dart';
import '../../data/providers/chat_providers.dart';

/// Slide-out chat drawer — "Ask Mythrix" floating assistant.
///
/// Width caps at 440 on desktop, full-width on mobile. The chat history
/// streams in real-time; the AI router decides whether responses come from
/// Gemini / Claude / GPT or the mock provider.
class ChatDrawer extends ConsumerStatefulWidget {
  const ChatDrawer({super.key});

  @override
  ConsumerState<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends ConsumerState<ChatDrawer> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send([String? prompt]) {
    final text = (prompt ?? _ctrl.text).trim();
    if (text.isEmpty) return;
    _ctrl.clear();

    // Intercept slash commands BEFORE sending to the AI router.
    if (text.startsWith('/')) {
      if (_runSlashCommand(text)) {
        _scrollToBottom();
        return;
      }
    }

    ref.read(chatMessagesProvider.notifier).send(text);
    _scrollToBottom();
  }

  /// Returns true if the input was a recognized slash command.
  bool _runSlashCommand(String text) {
    final parts = text.split(' ');
    final cmd = parts.first.toLowerCase();
    final arg = parts.sublist(1).join(' ');

    switch (cmd) {
      case '/help':
        Snack.info(context,
            'Commands: /post · /email · /campaign · /audience · /week · /go [screen]');
        return true;
      case '/week':
      case '/runweek':
      case '/run-week':
        AutoWeekService.runWeek(ref);
        Snack.success(context, '⚡ Week queued — open Scheduler + Email to review.');
        return true;
      case '/post':
        context.go('/app/social');
        Snack.info(context, arg.isEmpty
            ? 'Opening Social Scheduler.'
            : 'Opening Social Scheduler — paste this idea: "$arg"');
        return true;
      case '/email':
        context.go('/app/email');
        Snack.info(context, arg.isEmpty
            ? 'Opening Email Marketing.'
            : 'Opening Email Marketing — drafting "$arg"');
        return true;
      case '/campaign':
      case '/launch':
        context.go('/app/ads');
        Snack.info(context, 'Opening Ads Manager — pick a network to launch ${arg.isEmpty ? "your campaign" : "for: $arg"}');
        return true;
      case '/audience':
        context.go('/app/audiences');
        Snack.info(context, 'Opening Audiences — adopt a template or build custom.');
        return true;
      case '/conversion':
      case '/conversions':
        context.go('/app/conversions');
        return true;
      case '/integrations':
      case '/connect':
        context.go('/app/integrations');
        Snack.info(context, 'Opening Integrations — connect ${arg.isEmpty ? "any platform" : arg}');
        return true;
      case '/library':
        context.go('/app/library');
        return true;
      case '/automations':
      case '/rules':
        context.go('/app/automations');
        return true;
      case '/brand':
        context.go('/app/brand');
        return true;
      case '/go':
        if (arg.isNotEmpty) {
          context.go('/app/$arg');
          return true;
        }
        return false;
    }
    return false;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final providerName = ref.watch(aiRouterProvider).displayName;
    final hasReal = ref.watch(hasLiveAiProvider);

    final width = MediaQuery.sizeOf(context).width >= 720 ? 440.0 : double.infinity;

    // Auto-scroll on new messages
    ref.listen<List<ChatMessage>>(chatMessagesProvider, (_, __) => _scrollToBottom());

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: SizedBox(
          width: width,
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 48,
                  spreadRadius: -8,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              children: [
                _Header(providerName: providerName, hasReal: hasReal),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: messages.length,
                    itemBuilder: (_, i) => _ChatBubble(message: messages[i]),
                  ),
                ),
                const Divider(height: 1),
                _QuickActions(onTap: _send),
                _Composer(controller: _ctrl, onSubmit: _send),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.providerName, required this.hasReal});
  final String providerName;
  final bool hasReal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
          ),
          AppSpacing.hGapSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ask Mythrix', style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: hasReal ? AppColors.success : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        providerName,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Reset conversation',
            onPressed: () => ref.read(chatMessagesProvider.notifier).reset(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () =>
                ref.read(chatDrawerOpenProvider.notifier).state = false,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final scheme = Theme.of(context).colorScheme;

    final bg = isUser
        ? AppColors.mythrixViolet.withValues(alpha: 0.18)
        : scheme.surfaceContainerHigh;
    final fg = scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.white),
            ),
            AppSpacing.hGapSm,
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.md),
                  topRight: const Radius.circular(AppRadius.md),
                  bottomLeft: Radius.circular(isUser ? AppRadius.md : 4),
                  bottomRight: Radius.circular(isUser ? 4 : AppRadius.md),
                ),
                border: isUser
                    ? Border.all(color: AppColors.mythrixViolet.withValues(alpha: 0.35))
                    : Border.all(color: scheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.text.isEmpty && message.streaming)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: MythrixLoader(size: 18),
                    )
                  else
                    SelectableText(
                      message.text,
                      style: TextStyle(color: fg, fontSize: 13.5, height: 1.5),
                    ),
                  if (message.streaming && message.text.isNotEmpty) ...[
                    AppSpacing.vGapXs,
                    Row(
                      children: [
                        _BlinkDot(color: scheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        _BlinkDot(color: scheme.onSurface.withValues(alpha: 0.5), delay: 200),
                        const SizedBox(width: 4),
                        _BlinkDot(color: scheme.onSurface.withValues(alpha: 0.5), delay: 400),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            AppSpacing.hGapSm,
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outline),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.person_rounded, size: 14, color: scheme.onSurface.withValues(alpha: 0.7)),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlinkDot extends StatefulWidget {
  const _BlinkDot({required this.color, this.delay = 0});
  final Color color;
  final int delay;

  @override
  State<_BlinkDot> createState() => _BlinkDotState();
}

class _BlinkDotState extends State<_BlinkDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onTap});
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: kChatQuickActions.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
          itemBuilder: (_, i) {
            final a = kChatQuickActions[i];
            return ActionChip(
              label: Text(a.label, style: const TextStyle(fontSize: 11)),
              onPressed: () => onTap(a.prompt),
              visualDensity: VisualDensity.compact,
            );
          },
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSubmit});
  final TextEditingController controller;
  final void Function([String?]) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSubmit(),
              decoration: const InputDecoration(
                hintText: 'Ask Mythrix — or type / for commands',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          AppSpacing.hGapXs,
          Material(
            color: AppColors.mythrixViolet,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => onSubmit(),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm + 2),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
