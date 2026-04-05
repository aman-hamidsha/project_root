#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

find_running_server_pid() {
  local pid
  while IFS= read -r pid; do
    [ -n "$pid" ] || continue
    [ -d "/proc/$pid" ] || continue

    local cwd
    cwd="$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)"
    [ "$cwd" = "$SERVER_DIR" ] || continue

    local cmdline
    cmdline="$(tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null || true)"
    case "$cmdline" in
      *" bin/main.dart "*|*" bin/main.dart")
        echo "$pid"
        ;;
    esac
  done < <(pgrep -f "bin/main.dart" || true)
}

stopped_any=false
while IFS= read -r pid; do
  [ -n "$pid" ] || continue
  kill "$pid"
  echo "Stopped server process $pid."
  stopped_any=true
done < <(find_running_server_pid)

if [ "$stopped_any" = false ]; then
  echo "No running server process found for $SERVER_DIR."
fi
