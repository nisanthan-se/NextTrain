#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export PATH="${HOME}/flutter/bin:${PATH}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}PASS${NC} $1"; }
fail() { echo -e "${RED}FAIL${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}WARN${NC} $1"; }

echo "========================================"
echo " NextTrain E2E Verification"
echo "========================================"

# 1. Config files
echo ""
echo "--- Configuration ---"
test -f ios/Runner/GoogleService-Info.plist && pass "iOS Firebase plist" || fail "Missing iOS Firebase plist"
test -f android/app/google-services.json && pass "Android google-services.json" || fail "Missing Android google-services.json"
test -f lib/firebase_options.dart && pass "firebase_options.dart" || fail "Missing firebase_options.dart"
test -f .env && pass ".env present" || fail "Missing .env"

KEY=$(grep '^GEMINI_API_KEY=' .env | cut -d= -f2- | tr -d ' ')
if [ -n "$KEY" ]; then
  pass "Gemini API key configured"
else
  warn "Gemini API key empty — live assistant tests will be skipped"
fi

# 2. Live Gemini API
echo ""
echo "--- Gemini API (live) ---"
if [ -n "$KEY" ]; then
  HTTP=$(curl -s -o /tmp/nexttrain_gemini.json -w "%{http_code}" \
    -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${KEY}" \
    -H "Content-Type: application/json" \
    -d '{"contents":[{"parts":[{"text":"Reply with only: OK"}]}]}')

  if [ "$HTTP" = "200" ]; then
    pass "Gemini API responded HTTP 200"
  else
    MSG=$(python3 -c "import json; d=json.load(open('/tmp/nexttrain_gemini.json')); print(d.get('error',{}).get('message','unknown')[:120])" 2>/dev/null || echo "unknown")
    warn "Gemini API HTTP $HTTP — $MSG"
  fi
else
  warn "Skipped Gemini live check"
fi

# 3. Flutter unit + widget E2E tests
echo ""
echo "--- Flutter tests ---"
if ! command -v flutter >/dev/null 2>&1; then
  fail "Flutter not found in PATH"
fi

flutter pub get >/dev/null
flutter test test/ test/e2e/ && pass "All Flutter tests passed" || fail "Flutter tests failed"

echo ""
echo "========================================"
echo -e "${GREEN}E2E verification complete${NC}"
echo "========================================"
