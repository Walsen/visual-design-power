#!/bin/sh
# Health check for the visual-design power. Read-only: it reports, it never installs.
# Usage: sh check-setup.sh   (run from the user's project directory)

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
POWER_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
status=0

ok()   { echo "OK    $1"; }
warn() { echo "WARN  $1"; }
fail() { echo "FAIL  $1"; status=1; }

# Node.js and npx (Playwright MCP and Taste Skill's scripts need them)
if command -v node >/dev/null 2>&1; then
  ok "node $(node --version)"
else
  fail "node not found. Install Node.js 18 or newer (https://nodejs.org)."
fi
if command -v npx >/dev/null 2>&1; then
  ok "npx found"
else
  fail "npx not found. It ships with Node.js."
fi

# Playwright MCP package in the npx cache (first server start downloads it)
if ls "$HOME"/.npm/_npx/*/node_modules/@playwright/mcp >/dev/null 2>&1; then
  ok "@playwright/mcp is in the npx cache"
else
  warn "@playwright/mcp is not cached yet. The first server start downloads it; 'npx -y @playwright/mcp@latest --help' warms the cache."
fi

# A local Chromium for Playwright (also usable for headless screenshots)
case "$(uname -s)" in
  Darwin) PW_CACHE="$HOME/Library/Caches/ms-playwright" ;;
  *)      PW_CACHE="${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}" ;;
esac
SHELL_BIN=$(find "$PW_CACHE" -maxdepth 3 -type f -name 'chrome-headless-shell' 2>/dev/null | sort | tail -1)
if [ -n "$SHELL_BIN" ]; then
  ok "headless Chromium: $SHELL_BIN"
elif ls -d "$PW_CACHE"/chromium-* >/dev/null 2>&1; then
  ok "Playwright Chromium found in $PW_CACHE"
else
  warn "no Playwright Chromium in $PW_CACHE. 'npx playwright install chromium' installs it (about 150 MB)."
fi

# Impeccable launcher
LAUNCHER="$POWER_ROOT/skills/impeccable/scripts/impeccable"
if [ -x "$LAUNCHER" ]; then
  ok "impeccable launcher: $LAUNCHER"
elif [ -f "$LAUNCHER" ]; then
  warn "impeccable launcher is not executable. Run: chmod +x \"$LAUNCHER\""
else
  fail "impeccable launcher missing at $LAUNCHER"
fi

# Image conversion tools Impeccable can use
for t in cwebp sips magick ffmpeg; do
  if command -v "$t" >/dev/null 2>&1; then ok "image tool: $t"; break; fi
done

exit $status
