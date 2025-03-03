import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAzDKPa_J70tdNoXVjpriAKQbaSHV1YEo',
    appId: '1:570111942807:android:559b1afc880846c90c89d2',
    messagingSenderId: '570111942807',
    projectId: 'concord-cc2fb',
    storageBucket: 'concord-cc2fb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBi_Y1vs_nqkJxRtW5XEmHX6SPv1uRUgRs',
    appId: '1:570111942807:ios:f1f6dc3fdb9ce05d0c89d2',
    messagingSenderId: '570111942807',
    projectId: 'concord-cc2fb',
    storageBucket: 'concord-cc2fb.firebasestorage.app',
    iosClientId:
        '570111942807-4qqvvlv2rh5g6b8f8q9f8q9f8q9f8q9f.apps.googleusercontent.com',
  );
}
