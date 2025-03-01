# N8N Docker Stack

## Context

A basic docker stack to build a N8N Server Node to automate many task on your computer.

``` mermaid
flowchart TD
    A[N8N] -->|Cache, Memory| B(Redis-Stack)
    A[N8N] -->|Persistance, Vector Store| C(PGVector)  
```

AT least compose a server with :
- a N8N service : basic community N8N app for flow automation
- a Redis Service  : for caching, building **AI Agent Memory** for example
- a  / PGVector service : for data persistance on building **AI Vector Stores**.


This project proposes a docker compose file, you can personnalize, to build your own local docker stack. 


## Preparation


### Volumes creation

You need 3 volumes to persist all services configuration and Data

``` shell
# For N8N
docker volume create n8n_data

# For REDIS
docker volume create redis_data

# For PGVECTOR
docker volume create pgvector_data
```


### Building an automation network

You can now create a network for all you automation services, so then can interact esalily.
Declaring an external network give you the ability for the futur, to connect other nodes to you N8N stack, depending of you needs. 


``` shell
docker network create --driver=bridge n8n_network
```


### Configure Environment

In order to build your stack, you can see tha compose use Env Vars. 
So define a `.env`file in your project and choose the service passwords you want to use. 

Here is the vars you need to review/complete : 

``` shell
# The top level domain to serve from
DOMAIN_NAME=localhost
PORT=5678

SHARED_FOLDER=<local path you want to expose to N8N>

# Redis PASSWORDS
REDIS_PASSWORD=<your pass>

# PGVector
PGVECTOR_DB=automation
PGVECTOR_USER=n8n
PGVECTOR_PASSWORD=<your pass>

# Optional timezone to set which gets used by Cron-Node by default
GENERIC_TIMEZONE=Europe/Paris
```


## Compose Review


``` YAML
name: "n8n-automation"

#------------------------------------------------------------------------------
#
# NETWORKS
#
# -----------------------------------------------------------------------------
networks:
  n8n_network:
    external: true

#------------------------------------------------------------------------------
#
# VOLUMES
#
# -----------------------------------------------------------------------------
volumes:
  n8n_data:
    external: true
  redis_data:
    external: true
  pgvector_data:
    external: true


#------------------------------------------------------------------------------
#
# SERVICES
#
# -----------------------------------------------------------------------------
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n-engine
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=${DOMAIN_NAME}
      - N8N_PORT=${PORT}
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=http://${DOMAIN_NAME}:${PORT}/
      - GENERIC_TIMEZONE=${GENERIC_TIMEZONE}
      # Logging
      - N8N_LOG_LEVEL=INFO
      - N8N_LOG_FILE_LOCATION=/files/logs/n8n.logs
      - N8N_LOG_OUTPUT=console,file
      - N8N_LOG_FILE_SIZE_MAX=20
      - N8N_LOG_FILE_COUNT_MAX=10
    depends_on:
      - redis
      - pgvector
    volumes:
      - n8n_data:/home/node/.n8n
      # Your can personnalize here local folder you need/want to share
      - ${SHARED_FOLDER}/Files:/files
      - ${SHARED_FOLDER}/Logs:/files/logs
      - ${SHARED_FOLDER}/Backups:/files/backups
    networks:
      - n8n_network
      
  redis:
    image: redis/redis-stack:latest
    container_name: redis-service
    restart: unless-stopped
    ports:
      - "6379:6379"
      - "8001:8001"
    environment:
      - REDIS_ARGS=--requirepass ${REDIS_PASSWORD} --appendonly yes --save 900 1 --save 300 10 --save 60 10000 --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    networks:
      - n8n_network
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 10s

  pgvector:
    image: pgvector/pgvector:pg17
    container_name: pgvector-service
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${PGVECTOR_DB}
      POSTGRES_USER: ${PGVECTOR_USER}
      POSTGRES_PASSWORD: ${PGVECTOR_PASSWORD}
    volumes:
      - pgvector_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - n8n_network
    
```

After adjusting your compose, you can start your stack 

``` shell
docker compose up -d
```



## Scripts : backuping, updating

Before using all shell scripts described here, you have to update the following `n8n-env.sh` script :

``` shell
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
```

So adapt the **BACKUP_DIR** for your computer and change the **HEALTHCHECK_URL**. This is a _tutorial-level_ n8n flow to check that all N8N dependencies are functioning well.


### Backuping

I wrote a simple shell script to back up the volumes of different services. 
This helps prevent data loss from accidental mishandling.

For this backup, I mount the volumes in an ephemeral container for the duration of archiving its contents. 
This requires stopping the stack to ensure data consistency.

See [backup.sh](./backup.sh)



### Updating

N8N frequently releases fixes and updates. 
So, I wrote a shell script to update it easily. 
The first step in this update is to perform a preliminary backup.


See [update-n8n.sh](./update-n8n.sh)


### Restoring

I Wrote a script for restoring, but it need more work to be easy to use.
> Additional work to be done! 😉

See [restore.sh](./restore.sh)