# Codex Usage Menu

A small native macOS status-bar app that shows the remaining Codex account usage windows and reset
times. It talks only to the locally installed Codex app-server using the account already signed into
ChatGPT Desktop. It does not scrape a browser, save credentials, send prompts, or consume/reset
credits.

## What it shows

The menu-bar label is `Codex <remaining>%`. It represents the remaining capacity in the primary
Codex window returned by the account. Click the label to see every available account limit window,
including secondary windows where the account provides them, reset times, plan type, available
credits, reset-credit count, and any individual spend-control limit.

Use **Refresh Now** to request the current account snapshot immediately; otherwise the app refreshes
every 60 seconds. **Copy Summary** puts a short plain-text snapshot on the clipboard. The app only
reports usage; it has no action to purchase credits, redeem a reset, change a plan, or start Codex
work.

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
The app remains visible while its process runs. Quit it from **Quit Codex Usage Menu** in its menu.

## Requirements

- macOS 13 or later with Xcode Command Line Tools (for `swift build`);
- ChatGPT Desktop installed at `/Applications/ChatGPT.app`;
- an active Codex sign-in in ChatGPT Desktop.

The app dynamically reads the usage windows that the signed-in account makes available. A plan may
have one window, multiple rolling windows, credit information, or none of those fields. The app
shows only what the local Codex client returns and does not invent missing numbers.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| `Codex !` in the menu bar | Open ChatGPT Desktop, confirm its Codex sign-in, then choose **Refresh Now**. |
| App does not appear | Run the bundle commands above from a Terminal and check that `open dist/CodexUsageMenu.app` succeeds. |
| Build fails after moving the project | Delete only the generated `.build/` directory and rerun `./scripts/build-app-bundle.sh`. |
| Values differ from an older screenshot | Usage windows and reset times are live account values; refresh the menu or check Codex Settings → Usage for the first-party view. |

## Compatibility note

The first version uses the read-only `account/rateLimits/read` method exposed by the locally
installed Codex app-server. This avoids browser/session scraping but is coupled to the installed
Codex client. If a future ChatGPT Desktop update changes that protocol, rebuild the app and update
the bridge only after verifying the new local protocol remains read-only.

## Data boundary

The app starts the locally bundled `codex app-server`, sends only `initialize` and
`account/rateLimits/read`, reads the response in memory, and terminates the helper. It displays no
account identifier or reset-credit identifier, and writes no usage data to disk.
