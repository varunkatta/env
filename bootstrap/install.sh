#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BREW_DIR="$SCRIPT_DIR/brew"

usage() {
  cat <<'EOF'
Usage: ./bootstrap/install.sh <profile> [<profile> ...]

Run ./bootstrap/install.sh --list to see available profiles.
EOF
}

list_profiles() {
  local profile
  for profile in "$BREW_DIR"/*.Brewfile; do
    basename "$profile" .Brewfile
  done
}

is_valid_profile() {
  [[ -f "$BREW_DIR/$1.Brewfile" ]]
}

contains_profile() {
  local expected="$1"
  shift
  local profile
  for profile in "$@"; do
    [[ "$profile" == "$expected" ]] && return 0
  done
  return 1
}

if [[ "${1:-}" == "--list" ]]; then
  list_profiles
  exit 0
fi

if [[ "$#" -eq 0 ]]; then
  usage >&2
  exit 2
fi

for profile in "$@"; do
  if ! is_valid_profile "$profile"; then
    echo "Unknown bootstrap profile: $profile" >&2
    echo "Available profiles:" >&2
    list_profiles >&2
    exit 2
  fi
done

if contains_profile containers-orbstack "$@" && contains_profile containers-docker "$@"; then
  echo "Choose one container runtime: containers-orbstack or containers-docker." >&2
  exit 2
fi

"$SCRIPT_DIR/validate.sh"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it first; see bootstrap/manual/README.md." >&2
  exit 1
fi

for profile in "$@"; do
  brew bundle install --file "$BREW_DIR/$profile.Brewfile"
done
