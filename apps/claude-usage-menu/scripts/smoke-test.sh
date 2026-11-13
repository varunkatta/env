#!/usr/bin/env bash
# Builds the app and checks its local readers against a fixture Claude config directory: live
# session discovery, context parsing (skipping subagent and synthetic turns), and the statusline
# feed. Touches nothing outside a temporary directory, and turns the account read off, so it never
# reads the Keychain or the network and the feed stands in.
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"
swift build -c release
bin="$(swift build -c release --show-bin-path)/ClaudeUsageMenu"

fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
export CLAUDE_CONFIG_DIR="$fixture"
export CLAUDE_USAGE_MENU_NO_ACCOUNT=1

fail() { echo "FAIL: $*" >&2; exit 1; }

# --- Sessions -------------------------------------------------------------------------------
cwd="/tmp/fixture project.v2"
session_id="11111111-2222-3333-4444-555555555555"
project_dir="$fixture/projects/$(printf '%s' "$cwd" | sed 's/[^A-Za-z0-9]/-/g')"
mkdir -p "$fixture/sessions" "$project_dir"
now_ms=$(( $(date +%s) * 1000 ))

# A live session owned by this shell, and a dead one that must not be listed.
printf '{"pid":%d,"sessionId":"%s","cwd":"%s","startedAt":%d}\n' "$$" "$session_id" "$cwd" "$now_ms" \
  > "$fixture/sessions/$$.json"
printf '{"pid":%d,"sessionId":"dead","cwd":"/tmp","startedAt":%d}\n' 999999 "$now_ms" \
  > "$fixture/sessions/999999.json"
# pid 1 is alive but started at boot, long after this session claims to have started: a reused pid.
printf '{"pid":1,"sessionId":"reused","cwd":"/tmp","startedAt":1000}\n' > "$fixture/sessions/1.json"

cat > "$project_dir/$session_id.jsonl" <<'JSONL'
{"type":"user","message":{"role":"user","content":"hi"}}
{"type":"assistant","timestamp":"2026-11-11T10:00:00.123Z","message":{"model":"claude-test","usage":{"input_tokens":10,"cache_read_input_tokens":42000,"cache_creation_input_tokens":990}}}
{"contextUsage":{"raw_max_tokens":1000000}}
{"type":"assistant","isSidechain":true,"timestamp":"2026-11-11T10:01:00.000Z","message":{"model":"claude-sub","usage":{"input_tokens":5,"cache_read_input_tokens":3000,"cache_creation_input_tokens":0}}}
{"type":"assistant","timestamp":"2026-11-11T10:02:00.000Z","message":{"model":"<synthetic>","usage":{"input_tokens":0,"cache_read_input_tokens":0,"cache_creation_input_tokens":0}}}
JSONL

sessions_out="$("$bin" --dump-sessions)"
echo "$sessions_out"
grep -q "ctx=43000/1000000" <<<"$sessions_out" || fail "context should come from the main-thread turn with the reported 1M window"
grep -q "window reported" <<<"$sessions_out" || fail "window should be reported"
grep -q "model=claude-test" <<<"$sessions_out" || fail "subagent/synthetic model leaked"
grep -q "last turn 2026-11-11 10:00:00" <<<"$sessions_out" || fail "fractional-second timestamp not parsed"
grep -q "pid=999999" <<<"$sessions_out" && fail "dead session listed"
grep -q "pid=1 " <<<"$sessions_out" && fail "reused pid listed"
[ "$(grep -c 'ctx=' <<<"$sessions_out")" -eq 1 ] || fail "expected exactly one live session"

# --- Statusline feed --------------------------------------------------------------------------
reset=$(( $(date +%s) + 3600 ))
line="$(printf '{"session_id":"s","model":{"display_name":"Opus"},"workspace":{"current_dir":"/x/env"},"rate_limits":{"five_hour":{"used_percentage":28,"resets_at":%d},"seven_day":{"used_percentage":62.5,"resets_at":%d}}}' "$reset" "$reset" \
  | python3 scripts/statusline-capture.py)"
echo "$line"
[ "$line" = "Opus · env · 5h 72% · 7d 38%" ] || fail "unexpected status line: $line"
[ -f "$fixture/usage-menu/status.json" ] || fail "feed not written under CLAUDE_CONFIG_DIR"

# A bad payload must print nothing and not fail.
echo 'not json' | python3 scripts/statusline-capture.py || fail "bad payload broke the status line"

usage_out="$("$bin" --dump-usage || true)"
echo "$usage_out"
grep -q "via statusline" <<<"$usage_out" || fail "statusline feed not used as the fallback"
grep -q "7d all models: 38% left" <<<"$usage_out" || fail "7d window wrong"
grep -q "5h session: 72% left" <<<"$usage_out" || fail "5h window wrong"

echo "smoke test passed"
