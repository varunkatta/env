#!/usr/bin/env python3
"""Claude Code statusline command that doubles as the quota feed for Claude Usage Menu.

Claude Code invokes its statusline command on every render and pipes it a JSON payload that
includes the account's `rate_limits`. This script caches that block to
`~/.claude/usage-menu/status.json` for the menu bar app to read, then prints a status line.

That is the whole trick: the quota numbers arrive from Claude Code itself, so the menu bar app
never needs credentials, Keychain access, or a network call.

Reads stdin, writes one small file, prints one line. It never touches the network.
"""
import json
import os
import sys
import tempfile
import time

FEED_DIR = os.path.expanduser("~/.claude/usage-menu")
FEED_PATH = os.path.join(FEED_DIR, "status.json")
# Set CLAUDE_USAGE_MENU_DEBUG=1 to record the raw payload for diagnosing a missing quota feed.
DEBUG_PATH = os.path.join(FEED_DIR, "last-payload.json")

# Windows worth rendering in the status line itself, shortest first.
INLINE_WINDOWS = (("five_hour", "5h"), ("seven_day", "7d"))


def utilization(window):
    """Claude Code documents `used_percentage` (0-100); the rest are accepted defensively.

    Scale is decided by the key name, not the magnitude, so a genuine 0.5 percent reads as
    half a percent rather than half the allowance.
    """
    for key in ("used_percentage", "used_percent", "usedPercent", "percent_used"):
        value = window.get(key)
        if isinstance(value, (int, float)):
            return value / 100
    value = window.get("utilization")
    return value if isinstance(value, (int, float)) else None


def cache(payload):
    """Persist the quota block atomically so the app never reads a half-written file."""
    rate_limits = payload.get("rate_limits")
    if not isinstance(rate_limits, dict) or not rate_limits:
        return
    record = {
        "captured_at": time.time(),
        "session_id": payload.get("session_id"),
        "rate_limits": rate_limits,
    }
    os.makedirs(FEED_DIR, exist_ok=True)
    handle, temp_path = tempfile.mkstemp(dir=FEED_DIR, suffix=".tmp")
    try:
        with os.fdopen(handle, "w") as file:
            json.dump(record, file)
        os.replace(temp_path, FEED_PATH)
    except Exception:
        if os.path.exists(temp_path):
            os.unlink(temp_path)
        raise


def status_line(payload):
    parts = []

    model = (payload.get("model") or {}).get("display_name")
    if model:
        parts.append(model)

    directory = (payload.get("workspace") or {}).get("current_dir") or payload.get("cwd")
    if directory:
        parts.append(os.path.basename(directory.rstrip("/")) or directory)

    rate_limits = payload.get("rate_limits") or {}
    for key, label in INLINE_WINDOWS:
        window = rate_limits.get(key)
        if not isinstance(window, dict):
            continue
        used = utilization(window)
        if used is not None:
            parts.append(f"{label} {round((1 - used) * 100)}%")

    return " · ".join(parts)


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return  # Never let a bad payload break the user's status line.

    if os.environ.get("CLAUDE_USAGE_MENU_DEBUG"):
        try:
            os.makedirs(FEED_DIR, exist_ok=True)
            with open(DEBUG_PATH, "w") as file:
                json.dump({"keys": sorted(payload.keys()), "payload": payload}, file, indent=2)
        except Exception:
            pass

    try:
        cache(payload)
    except Exception:
        pass  # Caching is best effort; the status line still renders.

    line = status_line(payload)
    if line:
        print(line)


if __name__ == "__main__":
    main()
