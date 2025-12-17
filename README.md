# Cluster Infrastructure

Kubernetes cluster-level infrastructure components.

## Components

### cert-manager
SSL/TLS certificate management with Let's Encrypt integration.

### ingress-nginx
Nginx-based ingress controller for external traffic routing.

### external-secrets
External Secrets Operator for Vault integration.

### vault
HashiCorp Vault for secrets management.

### reloader
Automatic pod restart on ConfigMap/Secret changes.

## Deployment

Managed by ArgoCD. Changes pushed to this repository are automatically deployed to the cluster.

## Structure

Each component has:
- `argocd/` - ArgoCD Application definitions
- `kustomization.yaml` - Kustomize configuration
- Component-specific manifests or Helm values
