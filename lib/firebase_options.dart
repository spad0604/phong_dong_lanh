import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for this project.
///
/// Notes:
/// - This repo is currently configured for Flutter Web using the provided
///   Firebase config.
/// - If you want to run on Android/iOS/macOS/Windows/Linux, generate platform
///   configs with FlutterFire CLI and replace the unsupported branches.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'FirebaseOptions are not configured for this platform. '
          'Run on Web or configure the other platforms first.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Fuchsia is not supported.');
    }
  }

  /// Web Firebase configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDkJBtqBFeBsNzXTIR1M88dBrwoQviUhcA',
    appId: '1:724171452577:web:a99f013ae04d2d71fd40e0',
    messagingSenderId: '724171452577',
    projectId: 'phong-dong-lanh',
    authDomain: 'phong-dong-lanh.firebaseapp.com',
    storageBucket: 'phong-dong-lanh.firebasestorage.app',
    measurementId: 'G-4WHDBEGJMX',
    databaseURL: 'https://phong-dong-lanh-default-rtdb.firebaseio.com',
  );
}
