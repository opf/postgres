#!/usr/bin/env bash
set -euo pipefail

PG_MAJOR="${PG_MAJOR:-19}"
DEBIAN_CODENAME="${DEBIAN_CODENAME:-trixie}"

BASE_IMAGE="postgres:${PG_MAJOR}-${DEBIAN_CODENAME}"
PACKAGE="postgresql-${PG_MAJOR}-pgvector"

docker run --rm --entrypoint sh "$BASE_IMAGE" -c "
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

  printf '%s %s %s %s\n' \
    \"\$PG_VERSION\" \
    '$PG_MAJOR' \
    \"\$PGVECTOR_VERSION\" \
    \"\$PGVECTOR_DEBIAN_VERSION\"
"
