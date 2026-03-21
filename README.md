# chore_champ_app

Aplicatico para gerenciar atividades domésticas

## API local (Mac + iPhone físico)

1. Sobe a API no Mac (`chore_champ_api`: `python main.py` ou `uvicorn main:app --host 0.0.0.0 --port 8080`).
2. iPhone e Mac na **mesma rede Wi‑Fi**.
3. Ajusta o IP do Mac em `lib/src/constants/dev_machine_host.dart` (`kDefaultDevMachineHost`) ou corre com:
   `flutter run --dart-define=DEV_MACHINE_HOST=SEU_IP`
4. Para ver o IP no Mac: `ipconfig getifaddr en0` ou `bash scripts/print_mac_lan_ip.sh`

**Nota:** `10.0.2.2` é só para **emulador Android**. No iPhone usa o IP **real** do Mac (ex.: `10.0.0.x` ou `192.168.x.x`).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
