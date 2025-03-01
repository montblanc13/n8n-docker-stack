#!/usr/bin/zsh


# Dossier choisi pour déposer les backups (local machine)
BACKUP_DIR=~/Docker/Backups

# Endpoint de HealtCheck
# Adaptez ici l'URL en fonction de vitre WebHook local @see [Notif_Backup](./DOCKER___Stack_Health_Check.json)
# IIL faut pointer sur le webhook de votre flow (Activé -> URL de Production)
N8N_HEALTHCHECK_URL=http://localhost:5678/webhook/ff4fa298-3c06-4540-b426-9bedac2426ca


# Timestamp d'execution
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CALLPARAM=$(date --iso-8601=seconds)