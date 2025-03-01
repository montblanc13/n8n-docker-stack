#!/usr/bin/zsh

source n8n-env.sh

echo "***********************************************************************************"
echo "** N8N STACK BACKUP                                                              **"
echo "***********************************************************************************"
echo "BACKUP DIR  : $BACKUP_DIR"
echo "CALLPARAM   : $CALLPARAM"
echo "TIMESTAMP   : $TIMESTAMP"
echo "HEALTHCHECK : $N8N_HEALTHCHECK_URL"
echo "***********************************************************************************"

cd /home/slandeau/Workspaces/n8n-docker-stack

# On arrête la stack avant Backup -> consistance des fichiers
docker compose stop
sleep 5

echo "Backuping PGVECTOR..."
docker run --rm -v pgvector_data:/volume -v $BACKUP_DIR:/backup alpine sh -c "tar czf /backup/$TIMESTAMP-pgvector-data.tar.gz -C /volume ."

echo "Backuping REDIS..."
docker run --rm -v redis_data:/volume -v $BACKUP_DIR:/backup alpine sh -c "tar czf /backup/$TIMESTAMP-redis-data_.tar.gz -C /volume ."

echo "Backuping N8N..."
docker run --rm -v n8n_data:/volume -v $BACKUP_DIR:/backup alpine sh -c "tar czf /backup/$TIMESTAMP-n8n-data.tar.gz -C /volume ."


# On restart la stack
docker compose start

# On attend 30 sec que tous les services soient UP
echo "Waiting for 15 seconds before health check..."
sleep 15

# On check la stack N8N en envoyant à l'URL du webhook 
./check-stack.sh
