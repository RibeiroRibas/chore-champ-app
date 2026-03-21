/// IP do Mac na rede Wi‑Fi (mesma do iPhone / dispositivos físicos).
///
/// Se a API deixar de responder, o IP pode ter mudado (DHCP). No Mac:
/// `ipconfig getifaddr en0` ou `./scripts/print_mac_lan_ip.sh`
///
/// Alternativa sem editar este ficheiro:
/// `flutter run --dart-define=DEV_MACHINE_HOST=10.0.0.221`
const String kDefaultDevMachineHost = '10.0.0.221';
