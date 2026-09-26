import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _isInitialized = true;
    } catch (e) {
      // Firebase config may not be present yet (e.g. google-services.json pending)
      _isInitialized = false;
      debugPrint('Firebase initialization skipped or pending config: $e');
    }
  }
}
