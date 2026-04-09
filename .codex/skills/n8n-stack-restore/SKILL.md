---
name: n8n-stack-restore
description: Restore the Docker volumes for this repository when the user wants to recover n8n, Redis, and pgvector data from a saved backup set.
---

# N8N Stack Restore

Use this skill when the user wants to restore stack data from a previous backup.

## Preconditions

- Run from the repository root.
- Treat this as destructive for existing volume contents.
- Ensure the target backup archives exist in the `BACKUP_DIR` configured by `n8n-env.sh`.

## Workflow

1. Identify the backup prefix to restore, for example `20260409_103000`.
2. Run `./restore.sh` to restore the most recent backup set, or `./restore.sh <prefix>` to restore a specific set.
3. Confirm the stack restarts cleanly after the restore.
4. If a service fails, inspect `docker compose logs --tail=100` before retrying.

## Notes

- `restore.sh` stops the stack, clears the contents of `pgvector_data`, `redis_data`, and `n8n_data`, restores the archives, then starts the stack again.
- `./restore.sh latest` and `./restore.sh` behave the same way.
- The restore logic accepts both `*-redis-data.tar.gz` and the older legacy name `*-redis-data_.tar.gz`.
