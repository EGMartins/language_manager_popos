#!/usr/bin/env bash
#
# Instala o devlang: symlink no PATH + entrada no menu de aplicativos.
# Idempotente — pode rodar de novo depois de um `git pull`.
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"

mkdir -p "$BIN_DIR" "$APP_DIR"

ln -sfn "$REPO_DIR/devlang" "$BIN_DIR/devlang"
echo "  ✓ $BIN_DIR/devlang -> $REPO_DIR/devlang"

sed "s|@DEVLANG@|$REPO_DIR/devlang|g; s|@HOME@|$HOME|g" \
  "$REPO_DIR/devlang.desktop.in" > "$APP_DIR/devlang.desktop"
echo "  ✓ $APP_DIR/devlang.desktop"

update-desktop-database "$APP_DIR" 2>/dev/null || true

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "  ! Adicione ao seu shell rc:  export PATH=\"\$HOME/.local/bin:\$PATH\"" ;;
esac

echo "Pronto. Rode:  devlang --list"
