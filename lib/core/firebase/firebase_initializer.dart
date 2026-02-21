import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase initialization helper with error handling.
/// Supports web (with options) and mobile (auto-config from files).
class FirebaseInitializer {
  FirebaseInitializer._();

  /// Initialize Firebase. On web, requires firebase_options.dart.
  /// On mobile, uses google-services.json / GoogleService-Info.plist.
  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Web requires explicit options
        // Uncomment and configure after running: dart run flutterfire_cli configure
        // await Firebase.initializeApp(
        //   options: DefaultFirebaseOptions.currentPlatform,
        // );
        // For now, try default initialization (may fail if no config)
        await Firebase.initializeApp();
      } else {
        // Mobile: auto-config from google-services.json / GoogleService-Info.plist
        await Firebase.initializeApp();
      }
    } catch (e) {
      // Log error but don't crash - app can still run in mock mode
      debugPrint('Firebase initialization error: $e');
      if (kDebugMode) {
        rethrow;
      }
    }
  }

  /// Check if Firebase is initialized.
  static bool get isInitialized => Firebase.apps.isNotEmpty;
}
