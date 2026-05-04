# CI/CD Architecture

## Flow

```
Developer pushes code
        ↓
GitHub Actions
├── secret-scan (Gitleaks)
├── sast (Semgrep)
├── gosec / eslint
├── dependency-audit (Nancy / npm audit)
└── tests (with real postgres + rabbitmq)
        ↓
Build Docker image
        ↓
Push to GHCR (SHA tag)
        ↓
Trivy image scan
        ↓
Update image tag in SysteM/gitops/apps/{env}/
        ↓
ArgoCD detects change
        ↓
Deploy to namespace
        ↓
Health checks pass → rollout complete
Health checks fail → rollout stopped, old pods kept
```

## Branch Strategy

| Branch | Deploys to | Auto-sync |
|---|---|---|
| `staging` | staging namespace | yes |
| `main` | production namespace | no (PR required) |

## Required GitHub Secrets

| Secret | Repos | Description |
|---|---|---|
| `GITOPS_TOKEN` | all app repos | PAT with write access to SysteM |
| `GITHUB_TOKEN` | all repos | auto-provided by GitHub Actions |

## Image Tagging

All images are tagged with the git SHA:
```
ghcr.io/your-org/backend-api:abc1234
ghcr.io/your-org/oms-rms:abc1234
ghcr.io/your-org/mt5-bridge:abc1234
ghcr.io/your-org/market-data-bridge:abc1234
ghcr.io/your-org/ui-terminal:abc1234
ghcr.io/your-org/terminal-dashboard:abc1234
```

## Rollback Procedure

```bash
# Find previous working SHA in git log
cd SysteM
git log --oneline gitops/apps/production/backend-api/deployment.yaml

# Revert the image tag commit
git revert <commit-sha>
git push origin main

# ArgoCD auto-syncs and redeploys previous image
```
