#!/bin/bash
# Build M96 Control.app from src/ — reproducible, no Xcode project needed.
# Usage: bash scripts/build-app.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP="M96 Control.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"

rm -rf "$APP"
mkdir -p "$MACOS"

echo "→ Compiling src/main.swift (arm64, macOS 14 target)"
swiftc -O -parse-as-library -target arm64-apple-macosx14.0 src/main.swift -o "$MACOS/M96Control"

echo "→ Copying Info.plist"
cp src/Info.plist "$CONTENTS/Info.plist"

echo "→ Ad-hoc codesigning"
codesign --force --sign - "$APP"
codesign --verify --deep "$APP"

echo "✓ Built $APP"
file "$MACOS/M96Control"
