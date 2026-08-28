#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
binary_path="$(cd "$project_root" && swift build -c release --show-bin-path)/CodexUsageMenu"
app_path="$project_root/dist/CodexUsageMenu.app"

rm -rf "$app_path"
mkdir -p "$app_path/Contents/MacOS"
cp "$binary_path" "$app_path/Contents/MacOS/CodexUsageMenu"

cat > "$app_path/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key>
  <string>Codex Usage Menu</string>
  <key>CFBundleExecutable</key>
  <string>CodexUsageMenu</string>
  <key>CFBundleIdentifier</key>
  <string>com.varunkatta.codexusagemenu</string>
  <key>CFBundleName</key>
  <string>Codex Usage Menu</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

plutil -lint "$app_path/Contents/Info.plist" >/dev/null
printf '%s\n' "$app_path"
