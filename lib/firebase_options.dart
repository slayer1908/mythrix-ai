// Real Firebase configuration for the Mythrix.AI project.
// Web API keys are PUBLIC by design — security is enforced via Firestore
// rules + Auth, not by hiding this key. Safe to commit.
//
// To regenerate (e.g. after adding iOS/Android):
//   dart pub global activate flutterfire_cli
//   flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      // For now every platform uses the same Web app config. When you add the
      // iOS/Android apps in the Firebase console, replace these with the
      // platform-specific options that `flutterfire configure` generates.
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions is not configured for $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBbspz27gBPDHsFB_uc4h90NJiwZpr-lJo',
    authDomain: 'mythrix-ai.firebaseapp.com',
    projectId: 'mythrix-ai',
    storageBucket: 'mythrix-ai.firebasestorage.app',
    messagingSenderId: '801198570256',
    appId: '1:801198570256:web:2c1e260c2f81b24f624395',
    measurementId: 'G-EZNP3BZ3GW',
  );

  /// Always configured now that real values are wired.
  static bool get isConfigured => true;
}
