#!/usr/bin/env bash
set -euo pipefail

PG_MAJOR="${PG_MAJOR:-19}"
DEBIAN_CODENAME="${DEBIAN_CODENAME:-trixie}"

BASE_IMAGE="postgres:${PG_MAJOR}-${DEBIAN_CODENAME}"
PACKAGE="postgresql-${PG_MAJOR}-pgvector"

DIGEST=$(docker buildx imagetools inspect "$BASE_IMAGE" --format '{{.Manifest.Digest}}')

if [[ ! "$DIGEST" =~ ^sha256:[0-9a-f]{64}$ ]]; then
  echo "::error::Could not resolve digest of $BASE_IMAGE (got: '$DIGEST')."
  exit 1
fi

docker run --rm --quiet --entrypoint sh "${BASE_IMAGE}@${DIGEST}" -c "
  set -eu

  PG_VERSION=\$(postgres --version | awk '{print \$3}')

  apt-get update >/dev/null

  PGVECTOR_DEBIAN_VERSION=\$(apt-cache policy '$PACKAGE' |
    awk '/Candidate:/ { print \$2; exit }')

  if [ -z \"\$PGVECTOR_DEBIAN_VERSION\" ] || [ \"\$PGVECTOR_DEBIAN_VERSION\" = '(none)' ]; then
    echo 'Could not determine pgvector version' >&2
    exit 1
  fi

  PGVECTOR_VERSION=\$(echo \"\$PGVECTOR_DEBIAN_VERSION\" |
    sed -E 's/^[0-9]+://' | sed -E 's/-[^-]+$//')

  printf '%s %s %s %s %s %s\n' \
    '$DIGEST' \
    '$BASE_IMAGE' \
    \"\$PG_VERSION\" \
    '$PG_MAJOR' \
    \"\$PGVECTOR_VERSION\" \
    \"\$PGVECTOR_DEBIAN_VERSION\"
"
