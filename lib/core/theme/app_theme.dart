import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// MYTHRIX.AI ThemeData factory — supports both dark and light fusions.
class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    const surface = AppColors.darkSurface;
    const bg = AppColors.darkBg;
    const onSurface = AppColors.textHigh;

    final colorScheme = const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.mythrixViolet,
      onPrimary: Colors.white,
      primaryContainer: AppColors.darkSurface3,
      onPrimaryContainer: AppColors.textHigh,
      secondary: AppColors.mythrixCyan,
      onSecondary: Color(0xFF002B33),
      secondaryContainer: AppColors.darkSurface2,
      onSecondaryContainer: AppColors.textHigh,
      tertiary: AppColors.mythrixMagenta,
      onTertiary: Color(0xFF3B0040),
      error: AppColors.danger,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLowest: bg,
      surfaceContainerLow: surface,
      surfaceContainer: AppColors.darkSurface1,
      surfaceContainerHigh: AppColors.darkSurface2,
      surfaceContainerHighest: AppColors.darkSurface3,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorderStrong,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      onSurface: onSurface,
      muted: AppColors.textMid,
      systemOverlay: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  static ThemeData light() {
    const surface = AppColors.lightSurface;
    const onSurface = AppColors.textHighLight;

    final colorScheme = const ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.mythrixViolet,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEFEAFF),
      onPrimaryContainer: Color(0xFF2A1F70),
      secondary: AppColors.mythrixCyan,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE0F7FB),
      onSecondaryContainer: Color(0xFF003E47),
      tertiary: AppColors.mythrixMagenta,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLowest: AppColors.lightBg,
      surfaceContainerLow: AppColors.lightSurface1,
      surfaceContainer: AppColors.lightSurface2,
      surfaceContainerHigh: AppColors.lightSurface3,
      surfaceContainerHighest: Color(0xFFDDE2EE),
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorderStrong,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      onSurface: onSurface,
      muted: AppColors.textMidLight,
      systemOverlay: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.lightBg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color onSurface,
    required Color muted,
    required SystemUiOverlayStyle systemOverlay,
  }) {
    final textTheme = AppTypography.textTheme(onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
      canvasColor: colorScheme.surface,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: onSurface, size: 22),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemOverlay,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: onSurface),
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colorScheme.outline),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        space: 1,
        thickness: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mythrixViolet,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mythrixViolet,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          textStyle: textTheme.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHigh,
          foregroundColor: onSurface,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.mythrixViolet, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        side: BorderSide(color: colorScheme.outline),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: onSurface,
        unselectedLabelColor: muted,
        indicatorColor: AppColors.mythrixViolet,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.mythrixViolet
              : colorScheme.surfaceContainerHigh,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.mythrixViolet,
        inactiveTrackColor: colorScheme.surfaceContainerHigh,
        thumbColor: Colors.white,
        overlayColor: AppColors.mythrixViolet.withValues(alpha: 0.12),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        modalBackgroundColor: colorScheme.surfaceContainer,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        contentTextStyle: textTheme.bodyMedium,
        actionTextColor: AppColors.mythrixViolet,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: colorScheme.outline),
        ),
        textStyle: textTheme.bodySmall,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: AppColors.mythrixViolet.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.all(textTheme.labelMedium),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.mythrixViolet : muted,
            size: 24,
          ),
        ),
        height: 72,
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: AppColors.mythrixViolet.withValues(alpha: 0.18),
        selectedIconTheme: const IconThemeData(color: AppColors.mythrixViolet),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: AppColors.mythrixViolet),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: muted),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.mythrixViolet,
        linearTrackColor: AppColors.darkSurface3,
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(muted.withValues(alpha: 0.5)),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
    );
  }
}
