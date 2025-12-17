#!/bin/bash
set -e

VAULT_ADDR="http://vault.vault.svc.cluster.local:8200"
VAULT_TOKEN="root"

echo "===== Vault Secret Population Script ====="
echo "This script populates Vault with required secrets for External Secrets"
echo ""

# Export variables for vault CLI
export VAULT_ADDR
export VAULT_TOKEN

echo "1. Checking Vault status..."
vault status

echo ""
echo "2. Checking if KV v2 secrets engine is enabled..."
vault secrets list | grep "secret/" || vault secrets enable -path=secret kv-v2

echo ""
echo "3. Populating secrets..."

# PostgreSQL secrets
echo "  - postgresql/root"
vault kv put secret/postgresql/root \
  PASSWORD="$(openssl rand -base64 32)" \
  POSTGRES_PASSWORD="$(openssl rand -base64 32)" \
  REPLICATION_PASSWORD="$(openssl rand -base64 32)"

# Gitea secrets
echo "  - gitea/postgres"
vault kv put secret/gitea/postgres \
  PASSWORD="$(openssl rand -base64 32)"

echo "  - gitea/admin"
vault kv put secret/gitea/admin \
  USERNAME="bluemayne" \
  PASSWORD="Gi87345364@"

echo "  - gitea/minio"
vault kv put secret/gitea/minio \
  ROOT_USER="gitea" \
  ROOT_PASSWORD="$(openssl rand -base64 32)"

echo "  - gitea/runner"
vault kv put secret/gitea/runner \
  TOKEN="$(openssl rand -base64 32)"

# MinIO secrets
echo "  - minio/root"
vault kv put secret/minio/root \
  ROOT_USER="admin" \
  ROOT_PASSWORD="$(openssl rand -base64 32)"

# Grafana secrets
echo "  - monitoring/grafana"
vault kv put secret/monitoring/grafana \
  ADMIN_USER="admin" \
  ADMIN_PASSWORD="$(openssl rand -base64 32)"

# PostgreSQL monitoring
echo "  - monitoring/postgresql"
vault kv put secret/monitoring/postgresql \
  PASSWORD="$(openssl rand -base64 32)"

# Umami analytics
echo "  - analytics/umami"
vault kv put secret/analytics/umami \
  DATABASE_URL="postgresql://umami:$(openssl rand -base64 32 | tr -d '=+/')@postgresql.postgresql.svc.cluster.local:5432/umami" \
  HASH_SALT="$(openssl rand -hex 32)"

# Code Server
echo "  - dev-tools/code-server"
vault kv put secret/dev-tools/code-server \
  PASSWORD="$(openssl rand -base64 32)"

# PGWeb
echo "  - tools/pgweb"
vault kv put secret/tools/pgweb \
  DATABASE_URL="postgresql://bluemayne@postgresql.postgresql.svc.cluster.local:5432/postgres?sslmode=disable"

# PostgreSQL Dev
echo "  - postgresql-dev/root"
vault kv put secret/postgresql-dev/root \
  PASSWORD="$(openssl rand -base64 32)"

echo ""
echo "===== Secret population completed! ====="
echo ""
echo "To verify secrets, run:"
echo "  vault kv list secret/"
