import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyADywkOX-ZJ0f5-LnMlv4njhDYtgXC1i-U',
          appId: '1:352499223787:android:3a0538936b015d39b9c2ae',
          messagingSenderId: '352499223787',
          projectId: 'nexttrain-5cb99',
          storageBucket: 'nexttrain-5cb99.firebasestorage.app',
        );
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
          apiKey: 'AIzaSyBFR1_PUnF3OGxPS46iX9BT9SEwTzBlhTA',
          appId: '1:352499223787:ios:aca5e0edddee628eb9c2ae',
          messagingSenderId: '352499223787',
          projectId: 'nexttrain-5cb99',
          storageBucket: 'nexttrain-5cb99.firebasestorage.app',
          iosBundleId: 'nexttrain',
        );
}
