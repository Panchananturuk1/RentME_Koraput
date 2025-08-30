import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQPERlBiYPm2up0QHrsRL83ZrS8DfPwXM',
    appId: '1:25212022602:web:dbda9e1886aaf53e2ddbb3',
    messagingSenderId: '25212022602',
    projectId: 'rentme-koraput',
    authDomain: 'rentme-koraput.firebaseapp.com',
    storageBucket: 'rentme-koraput.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDQPERlBiYPm2up0QHrsRL83ZrS8DfPwXM',
    appId: '1:25212022602:android:dbda9e1886aaf53e2ddbb3',
    messagingSenderId: '25212022602',
    projectId: 'rentme-koraput',
    storageBucket: 'rentme-koraput.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDQPERlBiYPm2up0QHrsRL83ZrS8DfPwXM',
    appId: '1:25212022602:ios:dbda9e1886aaf53e2ddbb3',
    messagingSenderId: '25212022602',
    projectId: 'rentme-koraput',
    storageBucket: 'rentme-koraput.firebasestorage.app',
    iosBundleId: 'com.example.rentme_koraput',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDQPERlBiYPm2up0QHrsRL83ZrS8DfPwXM',
    appId: '1:25212022602:macos:dbda9e1886aaf53e2ddbb3',
    messagingSenderId: '25212022602',
    projectId: 'rentme-koraput',
    storageBucket: 'rentme-koraput.firebasestorage.app',
    iosBundleId: 'com.example.rentme_koraput',
  );
}