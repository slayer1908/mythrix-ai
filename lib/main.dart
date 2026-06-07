import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/api_client.dart';
import 'core/services/billing_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/telemetry_service.dart';

Future<void> main() async {
  // ----- Bind framework, lock orientations, edge-to-edge ------
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // ----- Env (best-effort) -----
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    if (kDebugMode) debugPrint('No .env file — using defaults.');
  }

  // ----- All non-UI services bootstrap in parallel where safe -----
  await Future.wait<void>([
    SecureStorageService.init().then((_) {}),
    HiveService.instance.init(),
    NotificationService.instance.init(),
    BillingService.instance.init(),
    FirebaseService.instance.init(),
  ]);

  // ----- HTTP client (depends on secure storage) -----
  ApiClient.init(
    baseUrl: dotenv.maybeGet('MYTHRIX_API_BASE_URL') ?? 'https://api.mythrix.ai/v1',
  );

  // ----- Run inside Sentry's guarded zone -----
  await TelemetryService.instance.bootstrap(() async {
    runApp(const ProviderScope(child: MythrixApp()));
  });
}
