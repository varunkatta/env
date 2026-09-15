# Claude Usage Menu

A small native macOS status-bar app that shows how much of the Claude subscription quota is left and
how much context each live Claude Code session is holding.

The app never refreshes, writes, or otherwise disturbs any credential. Its quota comes from three
layered sources, best available first:

1. **Account (live)** — a read-only request to the account usage endpoint, using the sign-in the
   `claude` CLI already holds. Used whenever that stored token is still valid.
2. **Statusline (snapshot)** — the `rate_limits` block Claude Code passes to its statusline command,
   cached to a file. Used when the account read is unavailable.
3. **Nothing** — when neither source is fresh, the label shows `Claude` with no number rather than a
   dead one, and the menu says why.

Session and context reporting is independent of all three and works everywhere.

## What it shows

The menu-bar label is `Claude <remaining>%` — the remaining capacity in whichever limit window is
closest to exhaustion. The number is dropped when the freshest reading is over 30 minutes old.

Open the menu for the detail:

- **Subscription usage** — every limit window the account reports (`5h`, `7d`, and any per-model or
  overage windows), each with a meter, the percentage left, and when it resets; then whether the
  reading is live or a snapshot, its source, and — when the account read is not in use — why.
- **Live sessions** — one row per Claude Code process still running on this machine, showing context
  fill as a meter, a percentage, and used/total tokens. Hover a row for its working directory,
  model, exact context and headroom, last turn time, start time, and pid.
- **Combined context** across all live sessions.

The account read refreshes every 60 seconds. The local parts are rebuilt whenever the menu opens.
**Copy Summary** puts a plain-text snapshot on the clipboard.

## Where the numbers come from

| Number | Source |
| --- | --- |
| Quota (live) | `GET https://api.anthropic.com/api/oauth/usage`, bearer token read from the `Claude Code-credentials` Keychain item |
| Quota (snapshot) | `rate_limits` from the statusline payload, cached to `~/.claude/usage-menu/status.json` |
| Live sessions | `~/.claude/sessions/*.json`, filtered to pids that are still running |
| Context size | The newest assistant message in `~/.claude/projects/*/<sessionId>.jsonl`: `input_tokens + cache_read_input_tokens + cache_creation_input_tokens` |
| Context window | `contextUsage.raw_max_tokens` in the transcript when present, otherwise inferred |

Context is read from the last assistant turn, so it already reflects any compaction that has
happened. Claude Code records the true context window only in a `contextUsage` entry, which it
writes when the context view is opened; when no such entry is within reach the app falls back to the
smallest published tier (200K, then 1M) that fits, and the session detail says `window inferred`.

## Install

Build and launch the app:

```bash
cd /Users/varunkatta/work/code/personal/env/apps/claude-usage-menu
./scripts/build-app-bundle.sh
open dist/ClaudeUsageMenu.app
```

Optionally register the statusline feed in `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "/Users/varunkatta/work/code/personal/env/apps/claude-usage-menu/scripts/statusline-capture.py"
  }
}
```

That script also prints a status line of its own — `Opus 5 · env · 5h 72% · 7d 38%` — so the quota
is visible inside a terminal session as well as in the menu bar.

The bundle is an agent-only app (`LSUIElement`), so it appears in the menu bar without a Dock icon.
It stays visible while its process runs; quit it from **Quit Claude Usage Menu** in its menu.

## Known limitation: both quota sources depend on terminal use

The Claude desktop app authenticates through its own host and **never touches the Keychain item
this app reads**, and it **never invokes the statusline command**. Both facts were measured on
2026-09-10 against five desktop sessions, all started after install, several actively working.

Only a `claude` session started **from a terminal** renews the stored token and feeds the
statusline. So in practice:

- After any terminal `claude` use, the account read is live for as long as that token lasts —
  observed at roughly 5½ hours — and refreshes every 60 seconds throughout.
- The statusline snapshot stands in for the 30 minutes after the terminal session's last render.
- If all work happens in the desktop Code tab, both go quiet and the label shows `Claude` with no
  number. The menu then says `Sign-in token expired … Any terminal claude session renews it`.

Live sessions and context sizes are unaffected — they read transcripts directly and work for
desktop sessions.

The app does not renew the token itself, deliberately. An OAuth refresh rotates the refresh token,
so renewing would mean rewriting the credential the `claude` CLI depends on — more access than a
menu bar readout should have.

## Run from source

```bash
swift run                                   # menu bar app
swift run ClaudeUsageMenu --dump-sessions   # live sessions, no quota needed
swift run ClaudeUsageMenu --dump-usage      # the quota reading the app would show, and its source
swift run ClaudeUsageMenu --dump-account    # the raw account response, for inspecting its shape
```

## Requirements

- macOS 13 or later with Xcode Command Line Tools (for `swift build`);
- Python 3 (present on macOS) for the optional statusline script;
- Claude Code installed and signed in.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Label shows `Claude` with no number | Both sources are stale. Open the menu for the reason; usually the token has expired. Run `claude` in a terminal once. |
| Menu says "Sign-in token expired" | Expected after a stretch of desktop-only use. Any terminal `claude` session renews it as a side effect. |
| Menu says "unrecognized format" | The account changed the usage response shape. Run `ClaudeUsageMenu --dump-account` and extend `StatusFeed`'s key lists. |
| Statusline shows model and directory but no percentages | That session has not completed a turn yet; `rate_limits` is only present after the first API response. |
| No status line at all in a terminal session | Check the path in `~/.claude/settings.json` is absolute and the script is executable. |
| Context shows `window inferred` | No `contextUsage` entry was in reach. Running `/context` once in that session records one. |
| Session missing from the list | Only sessions whose process is still alive are listed. |
| Build fails after moving the project | Delete only the generated `.build/` directory and rerun `./scripts/build-app-bundle.sh`. |

To diagnose a missing statusline feed, set `CLAUDE_USAGE_MENU_DEBUG=1` for a session and inspect
`~/.claude/usage-menu/last-payload.json`, which records the raw payload the hook received.

## Data boundary

The app makes exactly one kind of network request: a `GET` of the account usage endpoint, sent with
the stored bearer token. It sends no prompts and no session content anywhere.

The token is read through `/usr/bin/security find-generic-password -w` — the same tool Claude Code
uses to maintain the item, so the read is already on the item's access list and raises no macOS
prompt. Only the read form is used; the token comes back on a pipe, never on a command line. The
app never calls the token endpoint, never refreshes, and never writes to the Keychain.

Locally it reads `~/.claude/sessions`, the tails of transcripts under `~/.claude/projects`, and
`~/.claude/usage-menu/status.json`, and writes nothing outside its own window. Transcripts are read
tail-only and never modified. `--dump-account` prints usage data only, never the token.

The statusline script reads the payload Claude Code gives it, writes one small file atomically, and
prints one line. It makes no network requests and handles no credentials. It records only the
`rate_limits` block and the session id — no prompts, no session content.
