import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/theme_provider.dart';

class MythrixApp extends ConsumerWidget {
  const MythrixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: mode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      builder: (context, child) {
        // Cap text scale so designs hold up under user accessibility settings,
        // but never below 0.9.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(
              media.textScaler.scale(1).clamp(0.9, 1.25),
            ),
          ),
          child: child!,
        );
      },
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
        Locale('pt'),
        Locale('ja'),
        Locale('hi'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
