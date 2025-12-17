# Vault Setup for External Secrets

This directory contains Vault configuration for integrating with External Secrets Operator.

## Components

### 1. ClusterSecretStore (`cluster-secret-store.yaml`)
Defines a cluster-wide secret store that allows all namespaces to access Vault secrets.

### 2. ServiceAccount (`serviceaccount.yaml`)
ServiceAccount used by External Secrets Operator to authenticate with Vault using Kubernetes auth.

### 3. Vault Config Job (`vault-config-job.yaml`)
One-time job that configures Vault's Kubernetes auth backend and creates the necessary role and policy.

**This job:**
- Enables Kubernetes auth backend
- Creates `external-secrets` policy with read access to all secrets
- Creates `external-secrets` role for the ServiceAccount

### 4. Vault Populate Secrets Job (`vault-populate-secrets-job.yaml`)
One-time job that populates Vault with all required secrets for applications.

**⚠️ Important:** This job is NOT included in kustomization.yaml because it should only run once manually.

## Setup Instructions

### Initial Setup

1. **Deploy base infrastructure:**
   ```bash
   # ArgoCD will automatically sync and deploy:
   # - ServiceAccount
   # - ClusterSecretStore
   # - vault-config Job
   ```

2. **Wait for vault-config job to complete:**
   ```bash
   kubectl wait --for=condition=complete --timeout=300s job/vault-config -n vault
   ```

3. **Populate secrets (run once):**
   ```bash
   kubectl apply -f vault-populate-secrets-job.yaml
   kubectl wait --for=condition=complete --timeout=300s job/vault-populate-secrets -n vault
   ```

4. **Verify ExternalSecrets sync:**
   ```bash
   kubectl get externalsecret --all-namespaces
   ```

### Check Status

Use the provided status check script:
```bash
sudo kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: vault-debug
  namespace: vault
spec:
  containers:
  - name: vault
    image: hashicorp/vault:1.15
    command: ["/bin/sh", "-c", "sleep 3600"]
    env:
    - name: VAULT_ADDR
      value: "http://vault.vault.svc.cluster.local:8200"
    - name: VAULT_TOKEN
      value: "root"
  restartPolicy: Never
EOF

# Then exec into the pod
sudo kubectl exec -it vault-debug -n vault -- vault kv list secret/
```

Or use the check-status script:
```bash
cd scripts
./check-status.sh
```

## Secrets Structure

All secrets are stored in Vault's KV v2 secret engine at path `secret/`:

- `secret/postgresql/root` - PostgreSQL master credentials
- `secret/gitea/postgres` - Gitea database password
- `secret/gitea/admin` - Gitea admin credentials
- `secret/gitea/minio` - Gitea's MinIO credentials
- `secret/gitea/runner` - Gitea Actions runner token
- `secret/minio/root` - MinIO root credentials
- `secret/monitoring/grafana` - Grafana admin credentials
- `secret/monitoring/postgresql` - PostgreSQL exporter credentials
- `secret/analytics/umami` - Umami analytics credentials
- `secret/dev-tools/code-server` - Code Server password
- `secret/tools/pgweb` - PGWeb database connection
- `secret/postgresql-dev/root` - PostgreSQL dev credentials

## Troubleshooting

### ExternalSecrets not syncing

1. Check ClusterSecretStore status:
   ```bash
   kubectl get clustersecretstore vault-backend -o yaml
   ```

2. Check External Secrets Operator logs:
   ```bash
   kubectl logs -n external-secrets deployment/external-secrets
   ```

3. Verify Vault authentication:
   ```bash
   kubectl exec -n vault vault-0 -- vault list auth/kubernetes/role
   ```

### Vault in Dev Mode

⚠️ **Warning:** Vault is currently running in dev mode, which means:
- All data is stored in memory (not persistent)
- Data is lost when the pod restarts
- Auto-unseals with root token "root"

For production, consider migrating to:
- Raft storage backend with persistent volumes
- Proper seal/unseal process
- Vault auto-init and auto-unseal

## Migration to Production Mode

To migrate Vault to production mode:

1. Update `helm-values/vault.yaml`:
   ```yaml
   server:
     dev:
       enabled: false
     dataStorage:
       enabled: true
       size: 10Gi
     ha:
       enabled: true
       replicas: 3
   ```

2. Implement proper initialization and unsealing process
3. Migrate secrets from dev instance to production
4. Update root token and implement proper secret zero strategy
