#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/QuitOnClose.app"

mkdir -p "$APP/Contents/MacOS"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
xcrun swiftc -O -swift-version 5 \
  -framework AppKit \
  -framework ApplicationServices \
  -framework CoreGraphics \
  "$ROOT/Sources/main.swift" \
  -o "$APP/Contents/MacOS/QuitOnClose"
codesign --force --sign - "$APP"

echo "Собрано: $APP"
