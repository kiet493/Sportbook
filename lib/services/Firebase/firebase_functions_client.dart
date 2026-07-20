import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

const String functionsRegion = 'asia-southeast1';
final String functionsEmulatorHost =
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
    ? '10.0.2.2'
    : '127.0.0.1';
const int functionsEmulatorPort = 5001;

final FirebaseFunctions functions = FirebaseFunctions.instanceFor(
  region: functionsRegion,
);
