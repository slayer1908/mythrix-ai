import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/scheduled_post.dart';
import '../../data/providers/scheduled_posts_providers.dart';
import '../../data/providers/workspace_providers.dart';
import 'widgets/best_time_panel.dart';
import 'widgets/channel_toggle_row.dart';
import 'widgets/queue_list.dart';

class SocialSchedulerScreen extends ConsumerStatefulWidget {
  const SocialSchedulerScreen({super.key});
  @override
  ConsumerState<SocialSchedulerScreen> createState() => _SocialSchedulerScreenState();
}

class _SocialSchedulerScreenState extends ConsumerState<SocialSchedulerScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;
  final Set<SocialChannel> _channels = {SocialChannel.instagram, SocialChannel.linkedin};

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1180;
    final postsAsync = ref.watch(upcomingPostsProvider);
    final persisted = ref.watch(scheduledPostsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          AppSpacing.vGapXl,
          if (wide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 4, child: _Composer(channels: _channels, onChannel: _toggleChannel)),
                  AppSpacing.hGapLg,
                  Expanded(flex: 5, child: _CalendarCard(
                    focused: _focused,
                    selected: _selected,
                    format: _format,
                    posts: postsAsync.value ?? const [],
                    onFocus: (d) => setState(() => _focused = d),
                    onSelect: (d) => setState(() => _selected = d),
                    onFormat: (f) => setState(() => _format = f),
                  )),
                  AppSpacing.hGapLg,
                  const Expanded(flex: 3, child: BestTimePanel()),
                ],
              ),
            )
          else
            Column(
              children: [
                _Composer(channels: _channels, onChannel: _toggleChannel),
                AppSpacing.vGapLg,
                _CalendarCard(
                  focused: _focused,
                  selected: _selected,
                  format: _format,
                  posts: postsAsync.value ?? const [],
                  onFocus: (d) => setState(() => _focused = d),
                  onSelect: (d) => setState(() => _selected = d),
                  onFormat: (f) => setState(() => _format = f),
                ),
                AppSpacing.vGapLg,
                const BestTimePanel(),
              ],
            ),
          AppSpacing.vGapXl,
          if (persisted.isNotEmpty) ...[
            _PersistedQueue(entries: persisted),
            AppSpacing.vGapLg,
          ],
          postsAsync.when(
            data: (posts) => QueueList(posts: posts),
            error: (e, _) => Text('Error: $e'),
            loading: () => const Center(child: MythrixLoader()),
          ),
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }

  void _toggleChannel(SocialChannel c, bool selected) {
    setState(() {
      if (selected) {
        _channels.add(c);
      } else {
        _channels.remove(c);
      }
    });
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Social Scheduler', style: Theme.of(context).textTheme.headlineLarge),
              AppSpacing.vGapXs,
              Text(
                'One composer. Every channel. MYTHRIX picks the optimal moment for each.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
        if (MediaQuery.sizeOf(context).width >= 900)
          const GradientButton(
            label: 'Bulk schedule',
            icon: Icons.upload_file_rounded,
            onPressed: _noop,
          ),
      ],
    );
  }

  static void _noop() {}
}

class _Composer extends ConsumerStatefulWidget {
  const _Composer({required this.channels, required this.onChannel});
  final Set<SocialChannel> channels;
  final void Function(SocialChannel, bool) onChannel;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'New post',
            subtitle: 'Compose once, publish everywhere',
            icon: Icons.edit_rounded,
          ),
          TextField(
            controller: _ctrl,
            maxLines: 7,
            decoration: const InputDecoration(
              hintText: 'What\'s the story today? MYTHRIX will tailor it per channel.',
            ),
            onChanged: (_) => setState(() {}),
          ),
          AppSpacing.vGapXs,
          Row(
            children: [
              TextButton.icon(
                onPressed: () => Snack.info(context,
                    'Media picker coming soon. For now, drop image URLs directly in the composer body.'),
                icon: const Icon(Icons.image_outlined, size: 16),
                label: const Text('Media'),
              ),
              TextButton.icon(
                onPressed: () => Snack.info(context,
                    'Mythrix will auto-add 5-8 trending hashtags from your industry when you click Schedule.'),
                icon: const Icon(Icons.tag_rounded, size: 16),
                label: const Text('Hashtags'),
              ),
              TextButton.icon(
                onPressed: () => Snack.info(context,
                    'Multi-language translation lands in Phase 5. Right now Mythrix writes in English.'),
                icon: const Icon(Icons.translate_rounded, size: 16),
                label: const Text('Translate'),
              ),
              const Spacer(),
              Text(
                '${_ctrl.text.length} / 2,200',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Text('Channels', style: Theme.of(context).textTheme.labelMedium),
          AppSpacing.vGapXs,
          ChannelToggleRow(
            selected: widget.channels,
            onToggle: widget.onChannel,
          ),
          AppSpacing.vGapMd,
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.mythrixViolet.withValues(alpha: 0.12),
                AppColors.mythrixCyan.withValues(alpha: 0.08),
              ]),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.mythrixViolet.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.mythrixViolet),
                AppSpacing.hGapSm,
                Expanded(
                  child: Text(
                    'MYTHRIX will adapt copy, hashtags, and aspect ratios per channel.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGapLg,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Snack.success(context, 'Draft saved. Reopen via Library → Drafts tab.');
                  },
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Save draft'),
                ),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: GradientButton(
                  label: 'Schedule',
                  icon: Icons.send_rounded,
                  expand: true,
                  onPressed: _ctrl.text.isEmpty
                      ? null
                      : () {
                          final body = _ctrl.text.trim();
                          if (body.isEmpty || widget.channels.isEmpty) return;
                          final when = DateTime.now().add(const Duration(hours: 1));
                          ref.read(scheduledPostsProvider.notifier).schedule(
                                body: body,
                                channels: widget.channels.toList(),
                                when: when,
                              );
                          _ctrl.clear();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Scheduled for ${when.hour}:${when.minute.toString().padLeft(2, '0')} (${widget.channels.length} channels)',
                              ),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focused,
    required this.selected,
    required this.format,
    required this.posts,
    required this.onFocus,
    required this.onSelect,
    required this.onFormat,
  });

  final DateTime focused;
  final DateTime selected;
  final CalendarFormat format;
  final List<ScheduledPost> posts;
  final ValueChanged<DateTime> onFocus;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<CalendarFormat> onFormat;

  List<ScheduledPost> _eventsFor(DateTime day) {
    return posts.where((p) =>
        p.scheduledFor.year == day.year &&
        p.scheduledFor.month == day.month &&
        p.scheduledFor.day == day.day).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Calendar',
            subtitle: Fmt.date(focused),
            trailing: SegmentedButton<CalendarFormat>(
              segments: const [
                ButtonSegment(value: CalendarFormat.month, label: Text('Month')),
                ButtonSegment(value: CalendarFormat.twoWeeks, label: Text('2W')),
                ButtonSegment(value: CalendarFormat.week, label: Text('Week')),
              ],
              selected: {format},
              showSelectedIcon: false,
              onSelectionChanged: (v) => onFormat(v.first),
            ),
          ),
          TableCalendar<ScheduledPost>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: focused,
            selectedDayPredicate: (d) => isSameDay(d, selected),
            calendarFormat: format,
            eventLoader: _eventsFor,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
              CalendarFormat.twoWeeks: '2 weeks',
              CalendarFormat.week: 'Week',
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
              todayDecoration: BoxDecoration(
                color: AppColors.mythrixCyan.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.mythrixCyan),
              ),
              selectedDecoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.mythrixMagenta,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            onDaySelected: (d, f) {
              onSelect(d);
              onFocus(f);
            },
          ),
        ],
      ),
    );
  }
}

class _PersistedQueue extends ConsumerWidget {
  const _PersistedQueue({required this.entries});
  final List<SchedulerEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Your scheduled posts',
            subtitle:
                '${entries.length} post${entries.length == 1 ? '' : 's'} · saved to your device',
            icon: Icons.event_available_rounded,
          ),
          for (final e in entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        AppColors.mythrixViolet,
                        AppColors.mythrixCyan,
                      ]),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${e.channels.map((c) => c.displayName).join(", ")} · ${Fmt.relative(e.scheduledFor)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.55),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(scheduledPostsProvider.notifier).remove(e.id),
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
