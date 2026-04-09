---
name: n8n-stack-backup
description: Back up the Docker volumes for this repository when the user wants to save n8n, Redis, and pgvector data before an update, reset, or migration.
---

# N8N Stack Backup

Use this skill when the user wants to create a data backup of the local n8n stack.

## Preconditions

- Run from the repository root.
- Ensure `n8n-env.sh` points to the desired `BACKUP_DIR`.
- Expect a short service interruption because the stack is stopped before the archives are created.

## Workflow

1. Review `n8n-env.sh` if the backup location or webhook healthcheck matters.
2. Run `./backup.sh`.
3. Confirm that these archives were produced in `BACKUP_DIR` with the same timestamp prefix:
   - `*-pgvector-data.tar.gz`
   - `*-redis-data.tar.gz`
   - `*-n8n-data.tar.gz`
4. If requested, report the generated prefix so it can be reused for a later restore.

## Notes

- `backup.sh` stops the stack, archives the named volumes `pgvector_data`, `redis_data`, and `n8n_data`, then starts the stack again.
- Keep the three archives from a single timestamp together. Restoring mixed timestamps is risky.
