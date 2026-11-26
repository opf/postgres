ARG PG_MAJOR=19
ARG DEBIAN_CODENAME=trixie
# CI pins this to a digest (postgres:<major>-<codename>@sha256:...) so the image
# is built from exactly the base recorded in its labels.
ARG BASE_IMAGE=postgres:${PG_MAJOR}-${DEBIAN_CODENAME}
FROM ${BASE_IMAGE}

ARG PG_MAJOR
ARG PGVECTOR_VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-$PG_MAJOR-pgvector=$PGVECTOR_VERSION && \
    rm -rf /var/lib/apt/lists/*
