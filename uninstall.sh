#!/bin/zsh
set -euo pipefail

APP_NAME="QuitOnClose"
LABEL="local.ildar.QuitOnClose"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
pkill -x "$APP_NAME" 2>/dev/null || true
rm -f "$PLIST"
rm -rf "/Applications/${APP_NAME}.app"

echo "QuitOnClose удалён."
echo "При желании удалите его разрешения в Настройках → Конфиденциальность и безопасность."
