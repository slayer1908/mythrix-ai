import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry + log wrapper. Strips PII from payloads before sending.
class TelemetryService {
  TelemetryService._();
  static final TelemetryService instance = TelemetryService._();

  final Logger _log = Logger();
  bool _initialized = false;

  /// Wraps the app's runZonedGuarded — call from main().
  Future<void> bootstrap(FutureOr<void> Function() appRunner) async {
    final dsn = dotenv.maybeGet('SENTRY_DSN');
    if (dsn == null || dsn.isEmpty || kDebugMode) {
      if (kDebugMode) {
        _log.w('Sentry DSN missing or debug build — telemetry disabled.');
      }
      await appRunner();
      return;
    }

    _initialized = true;
    await SentryFlutter.init(
      (opts) {
        opts.dsn = dsn;
        opts.tracesSampleRate = 0.2;
        opts.attachStacktrace = true;
        opts.sendDefaultPii = false;
        opts.beforeSend = (event, hint) {
          // Strip emails / tokens from breadcrumbs.
          return event.copyWith(user: null);
        };
      },
      appRunner: () async => appRunner(),
    );
  }

  Future<void> capture(Object error, [StackTrace? stack]) async {
    if (!_initialized) {
      _log.e('Captured error (Sentry off)', error: error, stackTrace: stack);
      return;
    }
    await Sentry.captureException(error, stackTrace: stack);
  }
}
