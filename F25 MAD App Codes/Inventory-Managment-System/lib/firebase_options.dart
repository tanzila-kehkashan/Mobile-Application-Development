// File generated based on Firebase Console configuration
// This file contains Firebase configuration for all platforms

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-YQJYINjlTdABMidjE7-fQst7xPD6XIA',
    appId: '1:583762219876:web:bbf68541f0351a8e992071',
    messagingSenderId: '583762219876',
    projectId: 'inventory-managment-syst-31953',
    authDomain: 'inventory-managment-syst-31953.firebaseapp.com',
    storageBucket: 'inventory-managment-syst-31953.firebasestorage.app',
    measurementId: 'G-GFE981Q8WT',
  );

  // Android configuration - using same values for now
  // Update these if you add an Android app in Firebase Console
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-YQJYINjlTdABMidjE7-fQst7xPD6XIA',
    appId: '1:583762219876:web:bbf68541f0351a8e992071',
    messagingSenderId: '583762219876',
    projectId: 'inventory-managment-syst-31953',
    storageBucket: 'inventory-managment-syst-31953.firebasestorage.app',
  );

  // iOS configuration - using same values for now
  // Update these if you add an iOS app in Firebase Console
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-YQJYINjlTdABMidjE7-fQst7xPD6XIA',
    appId: '1:583762219876:web:bbf68541f0351a8e992071',
    messagingSenderId: '583762219876',
    projectId: 'inventory-managment-syst-31953',
    storageBucket: 'inventory-managment-syst-31953.firebasestorage.app',
    iosBundleId: 'com.example.inventoryManagementSystem',
  );

  // macOS configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB-YQJYINjlTdABMidjE7-fQst7xPD6XIA',
    appId: '1:583762219876:web:bbf68541f0351a8e992071',
    messagingSenderId: '583762219876',
    projectId: 'inventory-managment-syst-31953',
    storageBucket: 'inventory-managment-syst-31953.firebasestorage.app',
    iosBundleId: 'com.example.inventoryManagementSystem',
  );

  // Windows configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB-YQJYINjlTdABMidjE7-fQst7xPD6XIA',
    appId: '1:583762219876:web:bbf68541f0351a8e992071',
    messagingSenderId: '583762219876',
    projectId: 'inventory-managment-syst-31953',
    authDomain: 'inventory-managment-syst-31953.firebaseapp.com',
    storageBucket: 'inventory-managment-syst-31953.firebasestorage.app',
    measurementId: 'G-GFE981Q8WT',
  );
}
