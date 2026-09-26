import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return android;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBw8CM9p5mDnx7H3LZZDqZVIvF3jM0FWp4',
    appId: '1:419556241502:android:e9dcfedaa017a9b3fdc4cf',
    messagingSenderId: '419556241502',
    projectId: 'my-food-diary-4e679',
    storageBucket: 'my-food-diary-4e679.firebasestorage.app',
  );
}
