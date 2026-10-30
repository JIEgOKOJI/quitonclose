#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="QuitOnClose"
APP="/Applications/${APP_NAME}.app"
LABEL="local.ildar.QuitOnClose"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"

"$ROOT/build.sh"
pkill -x "$APP_NAME" 2>/dev/null || true
rm -rf "$APP"
ditto "$ROOT/${APP_NAME}.app" "$APP"

mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${APP}/Contents/MacOS/${APP_NAME}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
PLIST_EOF

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl enable "gui/$(id -u)/$LABEL"
launchctl kickstart "gui/$(id -u)/$LABEL"

echo "Установлено в $APP"
echo "Автозапуск включён: $PLIST"
