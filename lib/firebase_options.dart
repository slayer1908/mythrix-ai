// THIS IS A PLACEHOLDER FIREBASE OPTIONS FILE.
//
// To replace it with your real project config:
//   1. Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`
//   2. From the project root, run: `flutterfire configure`
//   3. Pick / create your Firebase project, select all platforms (web, ios,
//      android, macos), and this file will be regenerated automatically with
//      your real keys.
//
// Until then, Mythrix runs in "no-firebase" mode — auth uses the mock service,
// Firestore writes are no-ops, FCM is disabled.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return _stub('web');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _stub('android');
      case TargetPlatform.iOS:
        return _stub('ios');
      case TargetPlatform.macOS:
        return _stub('macos');
      case TargetPlatform.windows:
        return _stub('windows');
      case TargetPlatform.linux:
        return _stub('linux');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions is not configured for $defaultTargetPlatform.',
        );
    }
  }

  /// Placeholder options. Real values are filled in by `flutterfire configure`.
  static FirebaseOptions _stub(String platform) => FirebaseOptions(
        apiKey: 'PLACEHOLDER_API_KEY',
        appId: 'PLACEHOLDER_APP_ID_$platform',
        messagingSenderId: '0000000000',
        projectId: 'mythrix-placeholder',
        storageBucket: 'mythrix-placeholder.appspot.com',
      );

  /// Detect whether Firebase has been properly configured.
  static bool get isConfigured =>
      currentPlatform.apiKey != 'PLACEHOLDER_API_KEY';
}
