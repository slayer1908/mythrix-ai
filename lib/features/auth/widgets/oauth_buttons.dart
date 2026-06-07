import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_spacing.dart';

class OAuthButtons extends StatelessWidget {
  const OAuthButtons({super.key, required this.onProvider});
  final Future<void> Function(SocialProvider)? onProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OAuthBtn(
            icon: Icons.g_mobiledata_rounded,
            label: 'Google',
            onTap: onProvider == null
                ? null
                : () => onProvider!(SocialProvider.google),
          ),
        ),
        AppSpacing.hGapSm,
        Expanded(
          child: _OAuthBtn(
            icon: Icons.apple_rounded,
            label: 'Apple',
            onTap: onProvider == null
                ? null
                : () => onProvider!(SocialProvider.apple),
          ),
        ),
        AppSpacing.hGapSm,
        Expanded(
          child: _OAuthBtn(
            icon: Icons.window_rounded,
            label: 'Microsoft',
            onTap: onProvider == null
                ? null
                : () => onProvider!(SocialProvider.microsoft),
          ),
        ),
      ],
    );
  }
}

class _OAuthBtn extends StatelessWidget {
  const _OAuthBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          AppSpacing.hGapSm,
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
