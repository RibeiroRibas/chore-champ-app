#!/usr/bin/env python3
"""Gera assets/icon/app_icon.png (1024×1024) com troféu Material (Icons.emoji_events) em fundo laranja."""

from __future__ import annotations

import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# Mesmo glifo que Flutter: Icons.emoji_events → 0xE22C
EMOJI_EVENTS_CODEPOINT = 0xE22C
# AppColors.primary
BACKGROUND = (232, 93, 4)  # #E85D04
FOREGROUND = (255, 255, 255)
SIZE = 1024
FONT_SIZE = 620


def _material_icons_path() -> Path:
    root = os.environ.get("FLUTTER_ROOT", "").strip()
    if root:
        p = Path(root) / "bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf"
        if p.is_file():
            return p
    # FVM stable comum neste projeto
    fvm = Path.home() / "fvm/versions/stable/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf"
    if fvm.is_file():
        return fvm
    raise FileNotFoundError(
        "MaterialIcons-Regular.otf não encontrado. Defina FLUTTER_ROOT para o SDK Flutter."
    )


def main() -> None:
    app_dir = Path(__file__).resolve().parent.parent
    out = app_dir / "assets/icon/app_icon.png"
    out.parent.mkdir(parents=True, exist_ok=True)

    font_path = _material_icons_path()
    font = ImageFont.truetype(str(font_path), FONT_SIZE)
    glyph = chr(EMOJI_EVENTS_CODEPOINT)

    img = Image.new("RGB", (SIZE, SIZE), BACKGROUND)
    draw = ImageDraw.Draw(img)
    draw.text((SIZE // 2, SIZE // 2), glyph, font=font, fill=FOREGROUND, anchor="mm")

    img.save(out, format="PNG")
    print(f"Escrito: {out}")


if __name__ == "__main__":
    main()
