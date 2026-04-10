---
name: n8n-runtime-control
description: Stop, restart, and inspect logs for the n8n container in this repository when the user wants to control the running service and confirm it is healthy afterward.
---

# N8N Runtime Control

Use this skill when the user wants to stop `n8n`, restart it, or inspect its logs to confirm the service is healthy.

## Preconditions

- Run from the repository root.
- Target the Docker Compose service `n8n`. Prefer `docker compose` commands over direct `docker container` commands.
- Treat `stop` as a service interruption. Do not restart automatically unless the user asks for it.
- Prefer the service name `n8n` even though the container name is `n8n-engine`.

## Workflow

1. Check the current state with `docker compose ps n8n`.
2. Apply the requested action:
   - Stop: run `docker compose stop n8n`.
   - Restart: run `docker compose restart n8n`.
   - Logs only: skip the lifecycle action and keep the service state unchanged.
3. Inspect recent logs with `docker compose logs n8n --tail=200`.
4. When the user asked for a restart or health confirmation, verify the service is back with `docker compose ps n8n`.
5. Report whether the service is healthy based on status plus logs.

## Healthy Signals

- `docker compose ps n8n` shows the service as `running`.
- Logs do not show a restart loop, repeated crash, or immediate shutdown after startup.
- Logs show normal n8n startup messages, webhook initialization, or API readiness rather than fatal bootstrap errors.

## Notes

- If `restart` returns quickly but the logs show repeated failures, treat the restart as failed.
- If the stack is fully down and the user asks for `restart`, `docker compose restart n8n` may not be enough; use `docker compose up -d n8n` only if the current state shows the service is absent and the user intent is clearly to bring it back up.
- If PostgreSQL or Redis errors appear in the n8n logs, report them explicitly because the root cause may be outside the n8n container itself.
