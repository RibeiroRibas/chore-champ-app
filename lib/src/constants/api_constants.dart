import 'dart:io' show Platform;

import 'package:chore_champ_app/src/constants/dev_machine_host.dart';

class ApiConstants {
  ApiConstants._();

  /// URL completa (ex.: `flutter run --dart-define=API_BASE_URL=http://10.0.0.2:8080/api/v1`)
  static const String _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  /// IP do Mac na LAN (ex.: `flutter run --dart-define=DEV_MACHINE_HOST=192.168.1.50`)
  static const String _devMachineHostFromEnv = String.fromEnvironment(
    'DEV_MACHINE_HOST',
    defaultValue: '',
  );

  /// Base da API.
  ///
  /// - **Android emulador:** `http://10.0.2.2:8080` (alias para o localhost do PC).
  /// - **iPhone / simulador iOS:** IP do Mac na rede — ajuste [kDefaultDevMachineHost]
  ///   ou use `--dart-define=DEV_MACHINE_HOST=...`.
  /// - **Android físico:** use `--dart-define=API_BASE_URL=http://IP_DO_MAC:8080/api/v1`
  ///   ou o mesmo `DEV_MACHINE_HOST` com override manual em [resolveBaseUrl].
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
