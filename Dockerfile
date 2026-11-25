ARG PG_MAJOR=19
ARG DEBIAN_CODENAME=trixie
FROM postgres:$PG_MAJOR-$DEBIAN_CODENAME

ARG PG_MAJOR
ARG PGVECTOR_VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends postgresql-$PG_MAJOR-pgvector=$PGVECTOR_VERSION && \
    rm -rf /var/lib/apt/lists/*
