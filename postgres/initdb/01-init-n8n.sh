#!/bin/sh
set -eu

psql -v ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" \
  --dbname postgres \
  --set "n8n_db=$PGVECTOR_N8N_DB" \
  --set "n8n_user=$PGVECTOR_N8N_USER" \
  --set "n8n_password=$PGVECTOR_N8N_PASSWORD" \
  --set "client_db=$PGVECTOR_CLIENT_DB" \
  --set "client_user=$PGVECTOR_CLIENT_USER" \
  --set "client_password=$PGVECTOR_CLIENT_PASSWORD" <<'EOSQL'
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'n8n_user', :'n8n_password')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'n8n_user') \gexec

SELECT format('ALTER ROLE %I WITH LOGIN PASSWORD %L', :'n8n_user', :'n8n_password') \gexec

SELECT format('CREATE DATABASE %I OWNER %I', :'n8n_db', :'n8n_user')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'n8n_db') \gexec

SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'client_user', :'client_password')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'client_user') \gexec

SELECT format('ALTER ROLE %I WITH LOGIN PASSWORD %L', :'client_user', :'client_password') \gexec

SELECT format('CREATE DATABASE %I OWNER %I', :'client_db', :'client_user')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'client_db') \gexec
EOSQL

psql -v ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" \
  --dbname "$PGVECTOR_N8N_DB" \
  --set "n8n_db=$PGVECTOR_N8N_DB" \
  --set "n8n_user=$PGVECTOR_N8N_USER" \
  --set "n8n_schema=$PGVECTOR_N8N_SCHEMA" <<'EOSQL'
CREATE EXTENSION IF NOT EXISTS vector;

SELECT format('CREATE SCHEMA IF NOT EXISTS %I AUTHORIZATION %I', :'n8n_schema', :'n8n_user') \gexec
SELECT format('GRANT ALL PRIVILEGES ON DATABASE %I TO %I', :'n8n_db', :'n8n_user') \gexec
SELECT format('GRANT USAGE, CREATE ON SCHEMA %I TO %I', :'n8n_schema', :'n8n_user') \gexec
SELECT format('ALTER ROLE %I IN DATABASE %I SET search_path TO %I,public', :'n8n_user', :'n8n_db', :'n8n_schema') \gexec
EOSQL

psql -v ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" \
  --dbname "$PGVECTOR_CLIENT_DB" \
  --set "client_db=$PGVECTOR_CLIENT_DB" \
  --set "client_user=$PGVECTOR_CLIENT_USER" \
  --set "client_schema=$PGVECTOR_CLIENT_SCHEMA" <<'EOSQL'
CREATE EXTENSION IF NOT EXISTS vector;

SELECT format('CREATE SCHEMA IF NOT EXISTS %I AUTHORIZATION %I', :'client_schema', :'client_user') \gexec
SELECT format('GRANT ALL PRIVILEGES ON DATABASE %I TO %I', :'client_db', :'client_user') \gexec
SELECT format('GRANT USAGE, CREATE ON SCHEMA %I TO %I', :'client_schema', :'client_user') \gexec
SELECT format('ALTER ROLE %I IN DATABASE %I SET search_path TO %I,public', :'client_user', :'client_db', :'client_schema') \gexec
EOSQL
