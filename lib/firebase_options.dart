import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6Ds6puUZIdmzsf3h9ms3P2nw0zPiljSM',
    appId: '1:385820237799:android:9f29a4327b59e304c6e742',
    messagingSenderId: '385820237799',
    projectId: 'milexact-88618',
    storageBucket: 'milexact-88618.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBdI6rOXpe50hmHYiuo81xZCH4PoH_afs',
    appId: '1:385820237799:ios:95631bc0403d9eeec6e742',
    messagingSenderId: '385820237799',
    projectId: 'milexact-88618',
    storageBucket: 'milexact-88618.firebasestorage.app',
    iosClientId:
        '385820237799-r8ar7c5c50o60311luitqrkqpb5ckmqb.apps.googleusercontent.com',
    iosBundleId: 'com.milexact.app',
  );
}
