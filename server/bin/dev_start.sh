#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$SERVER_DIR"

if ! command -v dart >/dev/null 2>&1; then
  echo "Error: dart is not installed or not on PATH."
  exit 1
fi

find_running_server_pid() {
  local pid
  while IFS= read -r pid; do
    [ -n "$pid" ] || continue
    [ "$pid" != "$$" ] || continue
    [ -d "/proc/$pid" ] || continue

    local cwd
    cwd="$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)"
    [ "$cwd" = "$SERVER_DIR" ] || continue

    local cmdline
    cmdline="$(tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null || true)"
    case "$cmdline" in
      *" bin/main.dart "*|*" bin/main.dart")
        echo "$pid"
        return 0
        ;;
    esac
  done < <(pgrep -f "bin/main.dart" || true)

  return 1
}

if [ "${1:-}" = "--restart" ]; then
  shift
  if existing_pid="$(find_running_server_pid)"; then
    kill "$existing_pid"
    echo "Stopped existing server process $existing_pid."
  fi
elif existing_pid="$(find_running_server_pid)"; then
  echo "Server already running from $SERVER_DIR (pid $existing_pid)."
  echo "Use ./bin/dev_stop.sh to stop it, or ./bin/dev_start.sh --restart to replace it."
  exit 0
fi

dart bin/main.dart "$@"
