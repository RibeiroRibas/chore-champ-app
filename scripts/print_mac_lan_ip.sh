#!/usr/bin/env bash
# Mostra o IP local do Mac (Wi‑Fi) para configurar dev_machine_host.dart ou dart-define.
echo "IP sugerido para API no iPhone (mesma rede Wi‑Fi):"
ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "(não encontrado — veja Definições → Rede no Mac)"
