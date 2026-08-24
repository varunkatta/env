#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BREW_DIR="$SCRIPT_DIR/brew"

status=0

report_ok() { echo "ok: $1"; }
report_error() { echo "error: $1" >&2; status=1; }

if [[ "$(uname)" == "Darwin" ]]; then
  report_ok "macOS detected"
else
  report_error "this bootstrap is designed for macOS"
fi

if xcode-select -p >/dev/null 2>&1; then
  report_ok "Xcode Command Line Tools installed"
else
  report_error "Xcode Command Line Tools missing; run: xcode-select --install"
fi

if command -v brew >/dev/null 2>&1; then
  report_ok "Homebrew available"
else
  report_error "Homebrew missing; see bootstrap/manual/README.md"
fi

"$SCRIPT_DIR/validate.sh" || status=1

if [[ "$#" -gt 0 ]] && command -v brew >/dev/null 2>&1; then
  for profile in "$@"; do
    if [[ ! -f "$BREW_DIR/$profile.Brewfile" ]]; then
      report_error "unknown bootstrap profile: $profile"
      continue
    fi
    if brew bundle check --file "$BREW_DIR/$profile.Brewfile" >/dev/null; then
      report_ok "profile installed: $profile"
    else
      report_error "profile has missing packages: $profile"
    fi
  done
fi

exit "$status"
