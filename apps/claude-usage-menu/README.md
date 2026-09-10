# Claude Usage Menu

A small native macOS status-bar app that shows how much of the Claude subscription quota is left and
how much context each live Claude Code session is holding.

The app reads only local files. It makes no network requests, reads no credentials, and never
touches the Keychain. The quota numbers reach it through Claude Code itself: a statusline command
receives the account's rate limits on every render and caches them to a file the app reads.

## What it shows

The menu-bar label is `Claude <remaining>%` — the remaining capacity in whichever limit window is
closest to exhaustion. A trailing `?` means the reading has gone stale.

Open the menu for the detail:

- **Subscription usage** — every limit window the account reports (`5h`, `7d`, and any per-model or
  overage windows), each with a meter, the percentage left, and when it resets, plus how old the
  reading is.
- **Live sessions** — one row per Claude Code process still running on this machine, showing context
  fill as a meter, a percentage, and used/total tokens. Hover a row for its working directory,
  model, exact context and headroom, last turn time, start time, and pid.
- **Combined context** across all live sessions.

Everything on display is a local file read, so the whole view is rebuilt each time the menu opens
and is current whenever it is on screen. **Copy Summary** puts a plain-text snapshot on the
clipboard.

## Where the numbers come from

| Number | Source |
| --- | --- |
| Quota windows, reset times | The `rate_limits` block Claude Code passes to its statusline command, cached to `~/.claude/usage-menu/status.json` |
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

Then register the quota feed in `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "/Users/varunkatta/work/code/personal/env/apps/claude-usage-menu/scripts/statusline-capture.py"
  }
}
```

That script prints a status line of its own — `Opus 5 · env · 5h 72% · 7d 38%` — so the quota is
visible inside the session as well as in the menu bar.

The bundle is an agent-only app (`LSUIElement`), so it appears in the menu bar without a Dock icon.
It stays visible while its process runs; quit it from **Quit Claude Usage Menu** in its menu.

### First reading

Two things gate the first quota reading:

- Claude Code loads settings at session start, so **sessions already running when the statusline was
  installed will not feed the app**. New sessions will.
- The `rate_limits` block only appears once a session has completed a turn, because the limits are
  learned from an API response. A session that has been opened but not used yet reports nothing.

So the menu shows "No quota reading yet" until one freshly-started session has done one turn. Live
sessions and context sizes work immediately regardless — they do not depend on the statusline.

## Run from source

```bash
swift run                 # menu bar app
swift run ClaudeUsageMenu --dump-sessions   # live sessions, no quota needed
swift run ClaudeUsageMenu --dump-usage      # the cached quota reading
```

## Requirements

- macOS 13 or later with Xcode Command Line Tools (for `swift build`);
- Python 3 (present on macOS) for the statusline script;
- Claude Code installed and signed in.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| "No quota reading yet" | See **First reading** above. Confirm with `ClaudeUsageMenu --dump-usage`. |
| Quota reading marked stale | The feed only advances while a session renders its status line. Nothing has been running recently. |
| Status line shows model and directory but no percentages | That session has not completed a turn yet, so Claude Code has no rate limits to report. |
| No status line at all | Check the path in `~/.claude/settings.json` is absolute and the script is executable (`chmod +x`). |
| Context shows `window inferred` | No `contextUsage` entry was in reach. Running `/context` once in that session records one. |
| Session missing from the list | Only sessions whose process is still alive are listed. |
| Build fails after moving the project | Delete only the generated `.build/` directory and rerun `./scripts/build-app-bundle.sh`. |

## Data boundary

The app opens no sockets. It reads `~/.claude/sessions`, the tails of transcripts under
`~/.claude/projects`, and `~/.claude/usage-menu/status.json`, and writes nothing outside its own
window. Transcripts are read tail-only and never modified.

The statusline script reads the payload Claude Code gives it, writes one small file atomically, and
prints one line. It makes no network requests and handles no credentials. It records only the
`rate_limits` block and the session id — no prompts, no session content.

An earlier draft of this app read the OAuth token from the Keychain and called the account usage
endpoint directly. That approach was dropped: it required refreshing and rewriting the credential
that the `claude` CLI depends on, which is far more access than a menu bar readout should need. The
statusline route gets the same numbers with none of it.
