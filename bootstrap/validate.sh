#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly BREW_DIR="$SCRIPT_DIR/brew"

status=0

fail() {
  echo "policy error: $1" >&2
  status=1
}

matches_in() {
  local pattern="$1"
  local path="$2"
  grep -En "$pattern" "$path" 2>/dev/null || true
}

for profile in "$BREW_DIR"/*.Brewfile; do
  [[ -f "$profile" ]] || continue
  invalid_lines="$(matches_in '^[[:space:]]*(brew|cask)[[:space:]]+"[^"]+"[[:space:]]+.' "$profile")"
  if [[ -n "$invalid_lines" ]]; then
    fail "unsupported Brewfile syntax in ${profile#$PROJECT_ROOT/}: $invalid_lines"
  fi

  python_lines="$(matches_in '^[[:space:]]*(brew|cask)[[:space:]]+"(python|python@[^"]*|pyenv|conda|anaconda|miniconda)"' "$profile")"
  if [[ -n "$python_lines" ]]; then
    fail "Python must be managed by uv, not ${profile#$PROJECT_ROOT/}: $python_lines"
  fi

  postgres_lines="$(matches_in '^[[:space:]]*brew[[:space:]]+"postgresql' "$profile")"
  if [[ -n "$postgres_lines" && "$(basename "$profile")" != "postgres-local.Brewfile" ]]; then
    fail "PostgreSQL belongs only in postgres-local.Brewfile: $postgres_lines"
  fi

  redis_lines="$(matches_in '^[[:space:]]*brew[[:space:]]+"redis"' "$profile")"
  if [[ -n "$redis_lines" && "$(basename "$profile")" != "redis-local.Brewfile" ]]; then
    fail "Redis belongs only in redis-local.Brewfile: $redis_lines"
  fi
done

local_ai="$BREW_DIR/local-ai.Brewfile"
if [[ -f "$local_ai" ]]; then
  unexpected_local_ai="$(grep -Ev '^[[:space:]]*(#|$|brew[[:space:]]+"ollama")' "$local_ai" || true)"
  if [[ -n "$unexpected_local_ai" ]]; then
    fail "local-ai.Brewfile may contain only Ollama: $unexpected_local_ai"
  fi
fi

while IFS= read -r config; do
  python_mise="$(matches_in '^[[:space:]]*python[[:space:]]*=' "$config")"
  if [[ -n "$python_mise" ]]; then
    fail "mise must not manage Python: ${config#$PROJECT_ROOT/}: $python_mise"
  fi
done < <(find "$PROJECT_ROOT" -path "$PROJECT_ROOT/.git" -prune -o -name 'mise.toml' -type f -print)

while IFS= read -r script; do
  dangerous_lines="$(matches_in '(^|[[:space:]])(sudo|defaults[[:space:]]+write)([[:space:]]|$)' "$script")"
  if [[ -n "$dangerous_lines" ]]; then
    fail "bootstrap scripts may not use sudo or modify macOS preferences: ${script#$PROJECT_ROOT/}: $dangerous_lines"
  fi
done < <(find "$SCRIPT_DIR" -name '*.sh' -type f ! -name 'validate.sh' -print)

if [[ "$status" -eq 0 ]]; then
  echo "bootstrap policy: ok"
fi

exit "$status"
