import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../firebase_options.dart';

/// Centralized Firebase bootstrap.
///
/// Initializes Firebase if real options are configured, otherwise gracefully
/// degrades to no-op mode so the app still boots for local development.
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _initialized = false;
  bool _configured = false;
  final Logger _log = Logger();

  bool get isReady => _initialized && _configured;

  FirebaseAnalytics? _analytics;
  FirebaseAnalytics? get analytics => _analytics;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (!DefaultFirebaseOptions.isConfigured) {
      if (kDebugMode) {
        _log.w('Firebase not configured — running in no-firebase mode. '
            'Run `flutterfire configure` to enable.');
      }
      return;
    }

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _analytics = FirebaseAnalytics.instance;
      _configured = true;

      // Wire Crashlytics to FlutterError + PlatformDispatcher.
      if (!kDebugMode && !kIsWeb) {
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (e, s) {
          FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
          return true;
        };
      }

      _log.i('Firebase initialized.');
    } catch (e, s) {
      _log.e('Firebase init failed', error: e, stackTrace: s);
    }
  }

  /// Log an event to Firebase Analytics, no-op when unconfigured.
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    if (!isReady) return;
    await _analytics?.logEvent(name: name, parameters: params);
  }
}
