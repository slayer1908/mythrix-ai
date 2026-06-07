import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  MediaQueryData get mq => MediaQuery.of(this);

  // NOTE: BuildContext already exposes a nullable `Size? get size` for the
  // current RenderBox. We use `screenSize` to avoid the name clash.
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  bool get isMobile => screenSize.width < AppBreakpoints.mobile;
  bool get isTablet =>
      screenSize.width >= AppBreakpoints.mobile &&
      screenSize.width < AppBreakpoints.tablet;
  bool get isDesktop => screenSize.width >= AppBreakpoints.tablet;
  bool get isWide => screenSize.width >= AppBreakpoints.desktop;

  void showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error ? Theme.of(this).colorScheme.errorContainer : null,
      ),
    );
  }
}
