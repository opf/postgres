# PostgreSQL docker image for OpenProject

This is a custom Docker image created for the use with OpenProject. It features
the default Debian-based postgres image along with all the extensions, which
OpenProject relies on.

Next to default extensions, this includes:

- pgvector

It's available for the latest releases of these PostreSQL versions combined with
the latest versions of the extensions available for them:

- 16
- 17
- 18
- 19

It's built for multiple platforms:

- arm64
- amd64


## Test the build locally

```
# Build the image and publish locally
make build

# Find the proper tagged image
docker images openproject/postgres

# Start the server
docker run --rm --name postgres-test -e POSTGRES_PASSWORD=secret -p 5432:5432 {openproject/postgres:19.0-pgvector-0.8.7}

# Start a client
psql 'postgresql://postgres:secret@localhost:5432'
```

Verify that the expected tools are included:

(Example output for Postgres 19.0 and pgvector-0.8.7
```sql
postgres=# SELECT version();
                                                         version
--------------------------------------------------------------------------------------------------------------------------
 PostgreSQL 19.0 (Debian 19.0-2.pgdg13+1) on aarch64-unknown-linux-gnu, compiled by gcc (Debian 14.2.0-19) 14.2.0, 64-bit
(1 row)

postgres=# CREATE EXTENSION vector;
CREATE EXTENSION
postgres=# SELECT extversion FROM pg_extension WHERE extname = 'vector';
 extversion
------------
 0.8.7
(1 row)
```
