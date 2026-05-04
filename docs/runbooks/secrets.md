# Secrets Runbook

## Adding a new secret

```bash
# 1. Create plain secret (never commit this file)
kubectl create secret generic my-service-secrets \
  --namespace staging \
  --from-literal=MY_KEY=my_value \
  --dry-run=client -o yaml | \
kubeseal --format yaml > gitops/apps/staging/my-service/sealedsecret.yaml

# 2. Commit the sealed secret
git add gitops/apps/staging/my-service/sealedsecret.yaml
git commit -m "feat(secrets): add my-service staging secret"
git push

# 3. ArgoCD applies it automatically
```

## Rotating a secret

```bash
# 1. Generate new sealed secret with new value
kubectl create secret generic backend-api-secrets \
  --namespace production \
  --from-literal=JWT_SECRET=new_secret_value \
  --from-literal=... \
  --dry-run=client -o yaml | \
kubeseal --format yaml > gitops/apps/production/backend-api/sealedsecret.yaml

# 2. Commit and push
git add .
git commit -m "chore(secrets): rotate backend-api production JWT secret"
git push

# 3. ArgoCD applies, pods restart with new secret
```

## If cluster private key is lost

Sealed Secrets encryption is tied to the cluster private key.
If lost, existing SealedSecrets cannot be decrypted.

Prevention:
```bash
# Backup the private key immediately after cluster creation
kubectl get secret -n kube-system \
  -l sealedsecrets.bitnami.com/sealed-secrets-key \
  -o yaml > sealed-secrets-key-backup.yaml

# Store this file encrypted and offline — never in git
```

Recovery if key is lost:
- Restore key backup to new cluster
- Or re-create all SealedSecrets with new cluster key
