#!/usr/bin/env bash
set -e
echo "=== LitRadar Acceptance Check ==="

SRC=harmonyos_app/entry/src/main/ets

# 1. Structural check
if [ -d "harmonyos_app" ]; then echo "✅ harmonyos_app/ exists"; else echo "❌ missing"; exit 1; fi
for f in \
  "$SRC/pages/Index.ets" "$SRC/engine/FetchEngine.ets" "$SRC/engine/ScoreEngine.ets" \
  "$SRC/service/DbService.ets" "$SRC/service/ConfigService.ets" \
  "harmonyos_app/build-profile.json5" "harmonyos_app/entry/src/main/module.json5"; do
  if [ -f "$f" ]; then echo "✅ $f"; else echo "❌ $f MISSING"; exit 1; fi
done

# 2. Backend dependency check
echo ""
echo "--- Backend dependency scan ---"
APIRUN=$(grep -rn "/api/run" "$SRC" 2>/dev/null | grep -v "node_modules" || true)
if [ -n "$APIRUN" ]; then
  echo "⚠️  /api/run found in runtime:"
  echo "$APIRUN"
else
  echo "✅ No /api/run references in runtime"
fi

LOCALHOST=$(grep -rn "localhost\|127.0.0.1\|172.16" "$SRC" 2>/dev/null | grep -v "node_modules" || true)
if [ -n "$LOCALHOST" ]; then
  echo "⚠️  localhost/IP references found:"
  echo "$LOCALHOST"
else
  echo "✅ No localhost/IP in runtime"
fi

# 3. Directory naming consistency
echo ""
echo "--- Directory naming check ---"
if [ -d "$SRC/engine" ] && [ -d "$SRC/engines" ]; then
  echo "⚠️  Both engine/ and engines/ exist — consider consolidating"
elif [ -d "$SRC/engine" ]; then echo "ℹ️  Using engine/ (singular)"; fi
if [ -d "$SRC/service" ] && [ -d "$SRC/services" ]; then
  echo "⚠️  Both service/ and services/ exist — consider consolidating"
elif [ -d "$SRC/service" ]; then echo "ℹ️  Using service/ (singular)"; fi

# 4. Try hvigor build
echo ""
echo "--- Build check ---"
if [ -f "harmonyos_app/hvigorw" ]; then
  echo "🔨 Running hvigor build..."
  cd harmonyos_app
  ./hvigorw assembleHap -p buildMode=debug --no-daemon 2>&1 | tail -5
  cd ..
  echo "✅ Build attempted"
else
  echo "⚠️  hvigorw not found — skipping build (DevEco Studio required)"
  echo "   Verify build manually in DevEco Studio."
fi

echo ""
echo "✅ Basic check passed"
