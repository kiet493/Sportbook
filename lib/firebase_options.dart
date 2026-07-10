import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase options for the SportBook Firebase project.
///
/// Values can still be overridden with `--dart-define` if needed.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static const _apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyBAnbTZGX4MnsHx-7nSUY-pTqz0Jon7GjU',
  );
  static const _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'sportbook-e74c7',
  );
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '1002918623194',
  );
  static const _androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
    defaultValue: '1:1002918623194:android:00f76c6855d8a39cd6f2e3',
  );
  static const _appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:1002918623194:android:00f76c6855d8a39cd6f2e3',
  );
  static const _webAppId = String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: '1:1002918623194:android:00f76c6855d8a39cd6f2e3',
  );
  static const _iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const _authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'sportbook-e74c7.firebaseapp.com',
  );
  static const _databaseUrl = String.fromEnvironment(
    'FIREBASE_DATABASE_URL',
    defaultValue: 'https://sportbook-e74c7-default-rtdb.firebaseio.com',
  );
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'sportbook-e74c7.firebasestorage.app',
  );
  static const _androidClientId = String.fromEnvironment(
    'FIREBASE_ANDROID_CLIENT_ID',
    defaultValue:
        '1002918623194-ca46toc5ft27au4fdvvlu4kndnb19cjd.apps.googleusercontent.com',
  );
  static const _measurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
  );
  static const _iosBundleId = String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  static FirebaseOptions get currentPlatform {
    final appId = _platformValue(
      android: _androidAppId,
      ios: _iosAppId,
      web: _webAppId,
      fallback: _appId,
    );

    final options = FirebaseOptions(
      apiKey: _apiKey,
      appId: appId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      authDomain: _authDomain,
      databaseURL: _databaseUrl,
      storageBucket: _storageBucket,
      androidClientId: _androidClientId,
      measurementId: _measurementId,
      iosBundleId: _iosBundleId,
    );

    final missing = <String>[
      if (options.apiKey.isEmpty) 'FIREBASE_API_KEY',
      if (options.appId.isEmpty) 'FIREBASE_APP_ID',
      if (options.messagingSenderId.isEmpty) 'FIREBASE_MESSAGING_SENDER_ID',
      if (options.projectId.isEmpty) 'FIREBASE_PROJECT_ID',
    ];

    if (missing.isNotEmpty) {
      throw StateError('Thiếu cấu hình Firebase: ${missing.join(', ')}');
    }

    return options;
  }

  static String _platformValue({
    required String android,
    required String ios,
    required String web,
    required String fallback,
  }) {
    if (kIsWeb && web.isNotEmpty) return web;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return android.isNotEmpty ? android : fallback;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return ios.isNotEmpty ? ios : fallback;
    }
    return fallback;
  }
}
