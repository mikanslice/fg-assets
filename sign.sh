#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
  set -o allexport
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  set +o allexport
else
  echo "ERROR: $ENV_FILE not found" >&2
  exit 1
fi

: "${PRIVATE_KEY_PATH:?PRIVATE_KEY_PATH is not set in .env}"

FILES=(
  "$SCRIPT_DIR/additional.conf"
  "$SCRIPT_DIR/blacklist.txt"
  "$SCRIPT_DIR/blocked.html"
)

for f in "${FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "Skip (not found): $f"
    continue
  fi

  sig="${f}.sig"
  echo "Signing: $f -> $sig"
  openssl dgst -sha256 -sign "$PRIVATE_KEY_PATH" -out "$sig" "$f"
done

echo "Done."