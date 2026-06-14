#!/usr/bin/env bash
set -e

echo "=== LitRadar Basic Check ==="

# 1. Check harmonyos_app exists
if [ -d "harmonyos_app" ]; then
  echo "✅ harmonyos_app/ exists"
else
  echo "❌ harmonyos_app/ not found"
  exit 1
fi

# 2. Check key source files exist
for f in \
  "harmonyos_app/entry/src/main/ets/pages/Index.ets" \
  "harmonyos_app/entry/src/main/ets/engine/FetchEngine.ets" \
  "harmonyos_app/entry/src/main/ets/engine/ScoreEngine.ets" \
  "harmonyos_app/entry/src/main/ets/service/DbService.ets" \
  "harmonyos_app/entry/src/main/ets/service/ConfigService.ets" \
  "harmonyos_app/build-profile.json5" \
  "harmonyos_app/entry/src/main/module.json5"; do
  if [ -f "$f" ]; then
    echo "✅ $f"
  else
    echo "❌ $f MISSING"
    exit 1
  fi
done

# 3. Try hvigorw --version if present
if [ -f "harmonyos_app/hvigorw" ]; then
  echo "--- hvigorw check ---"
  ./harmonyos_app/hvigorw --version || true
fi

echo ""
echo "✅ Basic check passed"
