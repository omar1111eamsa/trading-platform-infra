# Rollback Runbook

## Application rollback

```bash
# Find the last working commit in gitops
git log --oneline gitops/apps/production/backend-api/deployment.yaml

# Revert to previous image tag
git revert <commit-sha>
git push origin main

# ArgoCD detects change and redeploys automatically
# Monitor in ArgoCD UI: https://argocd.example.com
```

## Emergency rollback (bypass git)

Only use this if git-based rollback is too slow.

```bash
# Get previous image SHA from GHCR or git history
PREVIOUS_SHA=abc1234

# Force image update directly
kubectl set image deployment/backend-api \
  backend-api=ghcr.io/trading-platform/backend-api:$PREVIOUS_SHA \
  -n production

# Monitor rollout
kubectl rollout status deployment/backend-api -n production

# IMPORTANT: after emergency rollback, immediately update git
# to match what is running, otherwise ArgoCD will revert it
```

## Database rollback

CloudNativePG handles postgres. Point-in-time recovery:

```bash
# List available backups
kubectl get backup -n infra

# Create recovery cluster from backup
# See CloudNativePG docs for full PITR procedure
```
