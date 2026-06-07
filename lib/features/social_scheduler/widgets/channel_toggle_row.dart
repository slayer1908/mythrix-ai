import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ChannelToggleRow extends StatelessWidget {
  const ChannelToggleRow({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<SocialChannel> selected;
  final void Function(SocialChannel, bool) onToggle;

  static const _meta = <SocialChannel, (IconData, Color)>{
    SocialChannel.instagram: (Icons.camera_alt_rounded, AppColors.mythrixMagenta),
    SocialChannel.facebook: (Icons.facebook_rounded, AppColors.mythrixIndigo),
    SocialChannel.twitter: (Icons.tag_rounded, AppColors.mythrixCyan),
    SocialChannel.linkedin: (Icons.work_outline_rounded, AppColors.mythrixIndigo),
    SocialChannel.tiktok: (Icons.music_note_rounded, AppColors.mythrixPink),
    SocialChannel.youtube: (Icons.play_arrow_rounded, AppColors.danger),
    SocialChannel.pinterest: (Icons.push_pin_rounded, AppColors.mythrixCoral),
    SocialChannel.threads: (Icons.alternate_email_rounded, AppColors.mythrixViolet),
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final c in SocialChannel.values)
          _ChannelChip(
            channel: c,
            icon: _meta[c]!.$1,
            color: _meta[c]!.$2,
            active: selected.contains(c),
            onChanged: (v) => onToggle(c, v),
          ),
      ],
    );
  }
}

class _ChannelChip extends StatelessWidget {
  const _ChannelChip({
    required this.channel,
    required this.icon,
    required this.color,
    required this.active,
    required this.onChanged,
  });

  final SocialChannel channel;
  final IconData icon;
  final Color color;
  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!active),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.18) : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: active ? color : Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              channel.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
