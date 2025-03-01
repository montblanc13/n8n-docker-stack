#!/usr/bin/zsh

source n8n-env.sh

echo "Healthchek on : $N8N_HEALTHCHECK_URL / $TIMESTAMP"
curl -X POST "$N8N_HEALTHCHECK_URL" \
     -H "Content-Type: application/json" \
     -d "{\"stamp\": \"$CALLPARAM\"}"
