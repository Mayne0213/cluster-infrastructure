#!/bin/bash

echo "===== Vault & External Secrets Status Check ====="
echo ""

echo "1. Checking Vault pod status..."
kubectl get pods -n vault

echo ""
echo "2. Checking vault-config job status..."
kubectl get jobs -n vault vault-config

echo ""
echo "3. Checking vault-config job logs..."
kubectl logs -n vault job/vault-config --tail=50 || echo "Job not completed yet"

echo ""
echo "4. Checking external-secrets ServiceAccount..."
kubectl get serviceaccount -n external-secrets external-secrets

echo ""
echo "5. Checking ClusterSecretStore..."
kubectl get clustersecretstore vault-backend

echo ""
echo "6. Checking ClusterSecretStore status..."
kubectl get clustersecretstore vault-backend -o jsonpath='{.status}' | jq '.'

echo ""
echo "7. Checking ExternalSecret status (umami example)..."
kubectl get externalsecret -n analytics umami-password

echo ""
echo "8. Checking ExternalSecret detailed status..."
kubectl describe externalsecret -n analytics umami-password | grep -A 10 "Status:"

echo ""
echo "9. Checking all ExternalSecrets with errors..."
kubectl get externalsecret --all-namespaces | grep -v "SecretSynced"

echo ""
echo "10. Checking External Secrets Operator logs..."
kubectl logs -n external-secrets deployment/external-secrets --tail=30
