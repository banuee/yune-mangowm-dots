#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/config"
FONTS_SRC="$SCRIPT_DIR/fonts"
CONFIG_DST="$HOME/.config"
FONTS_DST="$HOME/.local/share/fonts"

CONFIG_DIRS=(vibepanel ghostty fuzzel cava gtk-3.0 gtk-4.0)

PACKAGES=(vibepanel ghostty fuzzel cava bibata-cursor-theme-bin)

FONT_FILES=(
  "Crafty_Girls/CraftyGirls-Regular.ttf"
  "PlaypenSans/PlaypenSans-Light.ttf"
  "RedHatMono/RedHatMono-Light.ttf"
)

c_green="\033[1;32m"
c_yellow="\033[1;33m"
c_red="\033[1;31m"
c_reset="\033[0m"

info()  { echo -e "${c_green}[+]${c_reset} $1"; }
warn()  { echo -e "${c_yellow}[!]${c_reset} $1"; }
error() { echo -e "${c_red}[x]${c_reset} $1"; }

AUR_HELPER=""
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
else
    error "Не найден AUR-хелпер (yay или paru). Установите один из них и запусти скрипт снова."
    exit 1
fi
info "Используется AUR-хелпер: $AUR_HELPER"

info "Устанавливаются пакеты: ${PACKAGES[*]}"
"$AUR_HELPER" -S --needed --noconfirm "${PACKAGES[@]}"

mkdir -p "$CONFIG_DST"

for dir in "${CONFIG_DIRS[@]}"; do
    src="$CONFIG_SRC/$dir"
    dst="$CONFIG_DST/$dir"

    if [[ ! -d "$src" ]]; then
        warn "Пропускается $dir — не найдено в $CONFIG_SRC"
        continue
    fi

    if [[ -e "$dst" ]]; then
        backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
        warn "Найден существующий конфиг $dst, делаю бэкап -> $backup"
        mv "$dst" "$backup"
    fi

    cp -r "$src" "$dst"
    info "Установлен конфиг: $dir"
done

mkdir -p "$FONTS_DST"

for font in "${FONT_FILES[@]}"; do
    src="$FONTS_SRC/$font"
    if [[ ! -f "$src" ]]; then
        warn "Шрифт не найден: $font"
        continue
    fi
    cp -f "$src" "$FONTS_DST/"
    info "Установлен шрифт: $(basename "$font")"
done

if command -v fc-cache &>/dev/null; then
    fc-cache -f "$FONTS_DST" &>/dev/null
    info "Кэш шрифтов обновлён"
fi

info "Установка завершена."
