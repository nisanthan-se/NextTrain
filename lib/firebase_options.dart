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
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADywkOX-ZJ0f5-LnMlv4njhDYtgXC1i-U',
    appId: '1:352499223787:android:3a0538936b015d39b9c2ae',
    messagingSenderId: '352499223787',
    projectId: 'nexttrain-5cb99',
    storageBucket: 'nexttrain-5cb99.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBFR1_PUnF3OGxPS46iX9BT9SEwTzBlhTA',
    appId: '1:352499223787:ios:aca5e0edddee628eb9c2ae',
    messagingSenderId: '352499223787',
    projectId: 'nexttrain-5cb99',
    storageBucket: 'nexttrain-5cb99.firebasestorage.app',
    iosBundleId: 'nexttrain',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBCt5SC79_AyvQLy8L2fnZRByO5NtPQb8o',
    appId: '1:352499223787:web:4e7b64b1f40c3291b9c2ae',
    messagingSenderId: '352499223787',
    projectId: 'nexttrain-5cb99',
    authDomain: 'nexttrain-5cb99.firebaseapp.com',
    storageBucket: 'nexttrain-5cb99.firebasestorage.app',
    measurementId: 'G-WX7JFXF429',
  );
}
