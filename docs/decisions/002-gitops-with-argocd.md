# ADR 002 — GitOps with ArgoCD

## Status
Accepted

## Context
We needed a deployment strategy. Options: Watchtower,
Portainer webhooks, GitOps with ArgoCD.

## Decision
GitOps with ArgoCD, SysteM repo as single source of truth.

## Reasons
- Watchtower has no rollback and no health gates
- Portainer webhooks are better but still no automatic rollback
- ArgoCD gives automatic rollback on failed health checks
- Every deployment is a git commit — full audit trail
- Rollback is a git revert — no manual intervention
- Drift detection — if someone changes something manually ArgoCD corrects it

## Consequences
- All deployments go through git — no SSH deploys
- Team must use PRs for production changes
- Slightly more setup time upfront
