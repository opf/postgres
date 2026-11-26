#!/usr/bin/env bash
set -euo pipefail

PG_MAJOR="${PG_MAJOR:-19}"

IMAGE_NAME="openproject/postgres:${PG_MAJOR}"

if ! CONFIG="$(docker buildx imagetools inspect "$IMAGE_NAME" --format '{{json .Image}}')"; then
  echo "Could not inspect $IMAGE_NAME, assuming it doesn't exist yet."
  exit 1
fi

# Single-platform images return the config directly, multi-platform
# ones a map of platform => config. Labels are identical across platforms.
LABELS="$(jq -c '
  if has("config") then . else (to_entries | map(select(.key | test("^linux/"))) | .[0].value) end
  | .config.Labels // {}
' <<< "$CONFIG")"

DIGEST="$(jq -r '."org.opencontainers.image.base.digest" // empty' <<< "$LABELS")"
PGVECTOR_DEBIAN_VERSION="$(jq -r '."com.openproject.pgvector.version" // empty' <<< "$LABELS")"

printf '%s %s\n' $DIGEST $PGVECTOR_DEBIAN_VERSION
