import 'package:cloud_functions/cloud_functions.dart';

const String functionsRegion = 'asia-southeast1';
const String functionsEmulatorHost = '127.0.0.1';
const int functionsEmulatorPort = 5001;

final FirebaseFunctions functions = FirebaseFunctions.instanceFor(
  region: functionsRegion,
);
