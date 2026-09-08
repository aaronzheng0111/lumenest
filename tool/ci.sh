#!/usr/bin/env bash
# Local CI gate for AI-Mom-Baby (sdd/00-dev-environment T00-05)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/app"

export PATH="${FLUTTER_HOME:-$HOME/development/flutter}/bin:${PATH}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export JAVA_HOME="${JAVA_HOME:-/Applications/Android Studio.app/Contents/jbr/Contents/Home}"

cd "$APP"

if [[ ! -f env/dev.json ]]; then
  echo "Missing app/env/dev.json — copy from env/dev.json.example first." >&2
  exit 1
fi

echo "==> flutter pub get"
flutter pub get

echo "==> flutter analyze"
flutter analyze

echo "==> flutter test"
flutter test

echo "==> flutter build apk (dev / debug)"
flutter build apk --flavor dev --debug --dart-define-from-file=env/dev.json

APK="$APP/build/app/outputs/flutter-apk/app-dev-debug.apk"
echo "==> scan APK for leaked secrets"
"$ROOT/tool/scan_apk_secrets.sh" "$APK"

echo "OK: $APK"
