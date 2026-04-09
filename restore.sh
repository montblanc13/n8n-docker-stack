#!/usr/bin/zsh
set -euo pipefail

source n8n-env.sh

cd /home/slandeau/Workspaces/n8n-docker-stack

BACKUP_PREFIX="${1:-latest}"

resolve_archive() {
  local primary_pattern="$1"
  local fallback_pattern="${2:-}"
  local match=""

  if [[ "$BACKUP_PREFIX" == "latest" ]]; then
    match=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "$primary_pattern" | sort | tail -n 1)
    if [[ -z "$match" && -n "$fallback_pattern" ]]; then
      match=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "$fallback_pattern" | sort | tail -n 1)
    fi
  else
    match="$BACKUP_DIR/$BACKUP_PREFIX-${primary_pattern#\*}"
    if [[ ! -f "$match" && -n "$fallback_pattern" ]]; then
      match="$BACKUP_DIR/$BACKUP_PREFIX-${fallback_pattern#\*}"
    fi
  fi

  if [[ ! -f "$match" ]]; then
    echo "Archive not found for pattern: $primary_pattern" >&2
    exit 1
  fi

  echo "$match"
}

restore_volume() {
  local volume_name="$1"
  local archive_path="$2"

  echo "Restoring $volume_name from $archive_path..."
  docker run --rm \
    -v "$volume_name:/volume" \
    -v "$BACKUP_DIR:/backup" \
    alpine sh -c "rm -rf /volume/* /volume/.[!.]* /volume/..?* 2>/dev/null || true; tar xzf \"/backup/$(basename "$archive_path")\" -C /volume"
}

PGVECTOR_ARCHIVE=$(resolve_archive "*-pgvector-data.tar.gz")
REDIS_ARCHIVE=$(resolve_archive "*-redis-data.tar.gz" "*-redis-data_.tar.gz")
N8N_ARCHIVE=$(resolve_archive "*-n8n-data.tar.gz")

echo "Stopping stack before restore..."
docker compose stop
sleep 5

restore_volume "pgvector_data" "$PGVECTOR_ARCHIVE"
restore_volume "redis_data" "$REDIS_ARCHIVE"
restore_volume "n8n_data" "$N8N_ARCHIVE"

echo "Starting stack after restore..."
docker compose start

echo "Waiting for 15 seconds before health check..."
sleep 15

./check-stack.sh
