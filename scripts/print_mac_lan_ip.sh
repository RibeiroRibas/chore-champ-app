#!/usr/bin/env bash
echo "IP sugerido para API no iPhone (mesma rede Wi‑Fi):"
ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "(não encontrado — veja Definições → Rede no Mac)"
