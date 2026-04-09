---
name: n8n-stack-destroy
description: Remove the Docker stack for this repository when the user wants a full cleanup including container shutdown, named volume deletion, and network deletion for the local n8n environment.
---

# N8N Stack Destroy

Use this skill when the user wants to fully remove the Docker stack for this repository.

## Preconditions

- Run from the repository root.
- Treat this as destructive: confirm scope if the user sounds ambiguous.
- Preserve bind-mounted host directories unless the user explicitly asks to delete local files too.

## Workflow

1. Stop and remove containers with `docker compose down --remove-orphans`.
2. Remove named volumes with `docker volume rm n8n_data redis_data pgvector_data`.
3. Remove the network with `docker network rm n8n_bnetwork`.
4. Verify cleanup with `docker compose ps`, `docker volume ls`, and `docker network ls` if needed.

## Notes

- If a volume or network is still in use, inspect remaining containers before retrying.
- Do not delete `./data/` bind-mounted files unless the user explicitly requests a filesystem purge.
