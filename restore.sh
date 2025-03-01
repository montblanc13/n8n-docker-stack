#!/usr/bin/zsh
BACKUP_DIR=~/Backups

# Adapter le nom des archives (le backup créer les noms avec des timestamps)
docker run --rm -v mysql_data:/volume -v $BACKUP_DIR:/backup alpine sh -c "tar xzf /backup/mysql-data.tar.gz -C /volume"
docker run --rm -v n8n_data:/volume -v $BACKUP_DIR:/backup alpine sh -c "tar xzf /backup/n8n-data.tar.gz -C /volume"
docker run --rm -v redis_data:/volume -v $BACKUP_DIR:/backup alpine sh -c "tar xzf /backup/redis-data.tar.gz -C /volume"
docker run --rm -v pgvector_data:/volume -v $BACKUP_DIR:/backup alpine sh -c "tar xzf /backup/pgvector-data.tar.gz -C /volume"

