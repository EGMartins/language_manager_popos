#!/usr/bin/env bash
#
# Instala devlang + deveditor: symlinks no PATH + entradas no menu de aplicativos.
# Idempotente — pode rodar de novo depois de um `git pull`.
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"

mkdir -p "$BIN_DIR" "$APP_DIR"

for cmd in devlang deveditor; do
  ln -sfn "$REPO_DIR/$cmd" "$BIN_DIR/$cmd"
  echo "  ✓ $BIN_DIR/$cmd -> $REPO_DIR/$cmd"
done

for entry in devlang deveditor; do
  sed "s|@CMD@|$REPO_DIR/$entry|g; s|@HOME@|$HOME|g" \
    "$REPO_DIR/$entry.desktop.in" > "$APP_DIR/$entry.desktop"
  echo "  ✓ $APP_DIR/$entry.desktop"
done

update-desktop-database "$APP_DIR" 2>/dev/null || true

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    if [[ -f "$HOME/.profile" ]] && grep -q '.local/bin' "$HOME/.profile"; then
      echo "  · ~/.local/bin entra no PATH no próximo login (via ~/.profile)"
    else
      echo "  ! Adicione ao seu shell rc:  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
    ;;
esac

echo "Pronto. Rode:  devlang --list   |   deveditor --list"
