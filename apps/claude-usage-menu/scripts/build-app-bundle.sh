#!/usr/bin/env bash
# Builds dist/ClaudeUsageMenu.app. With --install, also copies it to ~/Applications, replaces any
# running copy, and launches it there, so a Launch at Login entry points at a stable path.
set -euo pipefail

install=false
for arg in "$@"; do
  case "$arg" in
    --install) install=true ;;
    *) echo "usage: $0 [--install]" >&2; exit 2 ;;
  esac
done

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
(cd "$project_root" && swift build -c release)
binary_path="$(cd "$project_root" && swift build -c release --show-bin-path)/ClaudeUsageMenu"
app_path="$project_root/dist/ClaudeUsageMenu.app"

rm -rf "$app_path"
mkdir -p "$app_path/Contents/MacOS"
cp "$binary_path" "$app_path/Contents/MacOS/ClaudeUsageMenu"

cat > "$app_path/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key>
  <string>Claude Usage Menu</string>
  <key>CFBundleExecutable</key>
  <string>ClaudeUsageMenu</string>
  <key>CFBundleIdentifier</key>
  <string>com.varunkatta.claudeusagemenu</string>
  <key>CFBundleName</key>
  <string>Claude Usage Menu</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.2.0</string>
  <key>CFBundleVersion</key>
  <string>2</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

plutil -lint "$app_path/Contents/Info.plist" >/dev/null
# An ad-hoc signature gives the bundle a stable identity, which Launch at Login needs.
codesign --force --sign - "$app_path" >/dev/null 2>&1 || echo "warning: ad-hoc signing failed" >&2

if $install; then
  target="$HOME/Applications/ClaudeUsageMenu.app"
  pkill -x ClaudeUsageMenu 2>/dev/null || true
  mkdir -p "$HOME/Applications"
  rm -rf "$target"
  cp -R "$app_path" "$target"
  open "$target"
  app_path="$target"
fi

printf '%s\n' "$app_path"
