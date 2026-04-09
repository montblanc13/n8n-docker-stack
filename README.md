# N8N Docker Stack

Local Docker stack for running the n8n Community edition with Redis Stack and PostgreSQL + pgvector.

## Services

- `n8n` on `http://localhost:5678`
- `redis/redis-stack:latest` protected by password
- `pgvector/pgvector:pg18-trixie` with dedicated databases, users, schemas, and healthchecks

The stack creates and uses:

- network `n8n_bnetwork`
- volumes `n8n_data`, `redis_data`, `pgvector_data`
- bind mounts under `./data/n8n/` for files, logs, and backups

## n8n Configuration

The compose file enables the following n8n settings:

- latest n8n image from `docker.n8n.io/n8nio/n8n:latest`
- execution retention pruned after 72 hours
- file logging to `./data/n8n/logs/n8n.log`
- community packages enabled
- public API enabled
- Swagger UI enabled
- PostgreSQL storage through the `pgvector` service

## Environment Variables

Copy `.env.example` to `.env` and replace the default secrets before starting the stack.

```dotenv
# n8n runtime
TZ=Europe/Paris
GENERIC_TIMEZONE=Europe/Paris
N8N_BIND_IP=127.0.0.1
N8N_HOST_PORT=5678
N8N_HOST=localhost
N8N_PROTOCOL=http
N8N_EDITOR_BASE_URL=http://localhost:5678
N8N_WEBHOOK_URL=http://localhost:5678/

# Host mounts used by n8n
N8N_FILES_DIR=./data/n8n/files
N8N_LOGS_DIR=./data/n8n/logs
N8N_BACKUPS_DIR=./data/n8n/backups

# Redis
REDIS_PASSWORD=change-me-redis

# PostgreSQL / pgvector
PGVECTOR_ADMIN_USER=postgres
PGVECTOR_ADMIN_PASSWORD=change-me-postgres-admin
PGVECTOR_N8N_DB=n8n
PGVECTOR_N8N_USER=n8n
PGVECTOR_N8N_PASSWORD=change-me-n8n-db
PGVECTOR_N8N_SCHEMA=n8n
PGVECTOR_CLIENT_DB=n8n_client
PGVECTOR_CLIENT_USER=n8n_client
PGVECTOR_CLIENT_PASSWORD=change-me-n8n-client-db
PGVECTOR_CLIENT_SCHEMA=n8n_client

# UI user for browser-based healthchecks
UI_USER_EMAIL=owner@example.com
UI_USER_PASSWORD=change-me-ui-password
```

Note: if a password contains `$`, escape it as `$$` in `.env` so Docker Compose reads it correctly.

## PostgreSQL Bootstrap

The file `postgres/initdb/01-init-n8n.sh` initializes PostgreSQL on first startup by:

- creating the dedicated n8n role and database
- creating a second client role and database
- enabling the `vector` extension in both databases
- creating dedicated schemas
- setting each role search path to its own schema plus `public`

The init script only runs when the PostgreSQL volume is empty.

## Start The Stack

```bash
mkdir -p data/n8n/files data/n8n/logs data/n8n/backups
docker compose config
docker compose pull
docker compose up -d
docker compose ps
```

Open n8n at `http://localhost:5678`.

## Stop Or Remove The Stack

Stop containers without deleting data:

```bash
docker compose stop
```

Remove containers, volumes, and the dedicated network:

```bash
docker compose down --remove-orphans
docker volume rm n8n_data redis_data pgvector_data
docker network rm n8n_bnetwork
```

## Backup And Restore

Project scripts are available for volume backup and restore:

- `./backup.sh` stops the stack, archives the named volumes, restarts the stack, then triggers the webhook healthcheck
- `./restore.sh [timestamp|latest]` restores the latest backup set or a specific timestamped backup, then restarts the stack and triggers the healthcheck
- `./check-stack.sh` sends a POST request to the webhook configured in `n8n-env.sh`

Adjust `BACKUP_DIR` and `N8N_HEALTHCHECK_URL` in `n8n-env.sh` to match your environment.

## Healthchecks

- Redis healthcheck uses `redis-cli --pass "$REDIS_PASSWORD" ping`
- PostgreSQL healthcheck uses `pg_isready -U "$POSTGRES_USER" -d postgres`
- UI healthchecks can authenticate with `UI_USER_EMAIL` and `UI_USER_PASSWORD` from `.env`

## Repository Notes

- Runtime data under `data/` is intentionally ignored by Git
- Playwright debug artifacts under `.playwright-mcp/` are intentionally ignored by Git
