---
name: n8n-stack-create
description: Create and bootstrap the Docker stack for this repository when the user wants to start the local n8n environment, pull fresh images, recreate containers, or verify that the stack is up.
---

# N8N Stack Create

Use this skill when the user wants to create, start, or recreate the Docker stack for this repository.

## Preconditions

- Run from the repository root.
- Prefer the local `.env` file. If it does not exist, copy `.env.example` first.
- Keep existing data volumes unless the user explicitly asks for a full reset.
- Ask user to validate `.env` before proceeding

## Workflow

1. Ensure bind-mount directories exist: `./data/n8n/files`, `./data/n8n/logs`, `./data/n8n/backups`.
2. Validate the compose file with `docker compose config`.
3. Pull current images with `docker compose pull`.
4. Start the stack with `docker compose up -d`.
5. Check status with `docker compose ps`.
6. If requested, inspect health with `docker compose logs --tail=100` for failing services.

## Notes

- The compose file already declares the `n8n_bnetwork` network and the named volumes `n8n_data`, `redis_data`, and `pgvector_data`, so Docker Compose creates them automatically when missing.
- Do not delete existing volumes during creation unless the user explicitly asks for a clean rebuild.
- If PostgreSQL was already initialized, changes in `docker-entrypoint-initdb.d` will not rerun automatically.
