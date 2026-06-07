import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tiny helper for consistent branded snackbars across the app.
/// Replaces empty `onPressed: () {}` callbacks with something meaningful.
class Snack {
  /// Quick info snackbar with the Mythrix violet leading icon.
  static void info(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded,
                color: AppColors.mythrixViolet, size: 16),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Success snackbar with green check.
  static void success(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 16),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
