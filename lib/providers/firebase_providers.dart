import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the Firebase startup error, if initialization failed.
///
/// The value is injected from `main.dart` so auth providers can show a
/// clear message instead of throwing a late "no Firebase app" exception.
final firebaseStartupErrorProvider = Provider<String?>((ref) => null);
