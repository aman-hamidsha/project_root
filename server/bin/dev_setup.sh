#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$SERVER_DIR"

if ! command -v dart >/dev/null 2>&1; then
  echo "Error: dart is not installed or not on PATH."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker is required for the bundled Postgres setup."
  echo "Install Docker, or start your own Postgres and update config/development.yaml."
  exit 1
fi

if [ ! -f config/passwords.yaml ]; then
  cp config/passwords.yaml.example config/passwords.yaml
  echo "Created config/passwords.yaml from the example template."
  echo "Update the placeholder secrets before using email auth in production."
fi

docker compose up -d
dart bin/main.dart --role maintenance --apply-migrations

cat <<'EOF'

Server setup complete.
Start the API with:
  ./bin/dev_start.sh
EOF
