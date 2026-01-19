import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS platform is not configured.');
      default:
        throw UnsupportedError('This platform is not supported.');
    }
  }
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC1pVtQic30Dz7DPkTg16oMUMuLLOK0xd4',
    appId: '1:603417697150:web:08d1ec6bd74f8ef809312f',
    messagingSenderId: '603417697150',
    projectId: 'campuscompanion-2305',
    authDomain: 'campuscompanion-2305.firebaseapp.com',
    storageBucket: 'campuscompanion-2305.appspot.com',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1pVtQic30Dz7DPkTg16oMUMuLLOK0xd4',
    appId: '1:603417697150:android:18c8048b810f21b209312f',
    messagingSenderId: '603417697150',
    projectId: 'campuscompanion-2305',
  );
}
