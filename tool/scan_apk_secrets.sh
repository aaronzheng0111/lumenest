#!/usr/bin/env bash
# Fail if an APK contains OpenAI-style secrets (sdd/00-dev-environment T00-07 / AC-00-F04)
set -euo pipefail

APK="${1:-}"
if [[ -z "$APK" || ! -f "$APK" ]]; then
  echo "Usage: $0 <path-to.apk>" >&2
  exit 2
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

unzip -qq -o "$APK" -d "$TMP"

# Match standard OpenAI API keys: sk-<20+ alphanumeric> or project/service tokens sk-proj-/sk-svcacct-/sk-admin-
if grep -RaoE '(sk-[A-Za-z0-9]{20,}|sk-(proj|svcacct|admin)-[A-Za-z0-9_-]{20,})' "$TMP" >/dev/null 2>&1; then
  echo "FAIL: found sk- secret-like string in APK: $APK" >&2
  grep -RaoE '(sk-[A-Za-z0-9]{20,}|sk-(proj|svcacct|admin)-[A-Za-z0-9_-]{20,})' "$TMP" | head -5 >&2 || true
  exit 1
fi

if grep -Ra 'OPENAI_API_KEY=' "$TMP" >/dev/null 2>&1; then
  echo "FAIL: found OPENAI_API_KEY= in APK: $APK" >&2
  exit 1
fi

echo "PASS: no sk-/OPENAI_API_KEY leaks in $APK"
