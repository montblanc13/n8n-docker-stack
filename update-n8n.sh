#!/usr/bin/zsh


source n8n-env.sh

echo "***********************************************************************************"
echo "** N8N STACK UPDATE                                                              **"
echo "***********************************************************************************"
echo "BACKUP DIR  : $BACKUP_DIR"
echo "CALLPARAM   : $CALLPARAM"
echo "TIMESTAMP   : $TIMESTAMP"
echo "HEALTHCHECK : $N8N_HEALTHCHECK_URL"
echo "***********************************************************************************"

echo "Etape 1: Backuping..."
./backup.sh

echo "Etape 2: Arrêt de la stack..."
docker compose down

echo "Etape 3: Update des images..."
docker compose pull

echo "Etape 4: Redémarrage de la stack..."
docker compose up -d

echo "Nouveau Checking des services..."
sleep 20
./check-stack.sh