# Codex Usage Menu

A small native macOS status-bar app that shows the remaining Codex account usage windows and reset
times. It talks only to the locally installed Codex app-server using the account already signed into
ChatGPT Desktop. It does not scrape a browser, save credentials, send prompts, or consume/reset
credits.

## Run

```bash
cd /Users/varunkatta/work/code/personal/env/apps/codex-usage-menu
swift run
```

The app appears as `Codex <remaining>%` on the right side of the macOS menu bar. Click it to see
each active limit window, reset time, credit availability, and a manual refresh action.

## Build a release binary

```bash
swift build -c release
"$(swift build -c release --show-bin-path)/CodexUsageMenu"
```

The process must remain running for the menu-bar item to remain visible. The first version does not
install a login item; close it with **Quit Codex Usage Menu** from its menu.

## Build and launch a macOS app bundle

```bash
./scripts/build-app-bundle.sh
open dist/CodexUsageMenu.app
```

The bundle is an agent-only app (`LSUIElement`), so it appears in the menu bar without a Dock icon.

## Data boundary

The app starts the locally bundled `codex app-server`, sends only `initialize` and
`account/rateLimits/read`, reads the response in memory, and terminates the helper. It displays no
account identifier or reset-credit identifier, and writes no usage data to disk.
