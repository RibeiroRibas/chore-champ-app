import 'dart:io' show Platform;

import 'package:chore_champ_app/src/constants/dev_machine_host.dart';

class ApiConstants {
  ApiConstants._();

  static const String _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  static const String _devMachineHostFromEnv = String.fromEnvironment(
    'DEV_MACHINE_HOST',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_apiBaseUrlFromEnv.isNotEmpty) {
      return _apiBaseUrlFromEnv;
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/v1';
    }

    final host = _devMachineHostFromEnv.isNotEmpty
        ? _devMachineHostFromEnv
        : kDefaultDevMachineHost;
    return 'http://$host:8080/api/v1';
  }

  static const int codeUserNotFound = 404301;
}
