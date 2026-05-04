# ADR 005 — Sealed Secrets for secret management

## Status
Accepted

## Context
Secrets need to be stored somewhere safe.
Options: plaintext in git (never), Vault, Doppler, Sealed Secrets.

## Decision
Sealed Secrets by Bitnami.

## Reasons
- Secrets encrypted in git — same GitOps workflow as everything else
- No external dependency (no Vault server, no Doppler account)
- Decryption only possible by the cluster — safe to commit
- ArgoCD applies them like any other manifest
- kubeseal CLI is simple to use

## Consequences
- Sealed Secrets private key must be backed up immediately
- If cluster is lost without key backup, secrets must be re-created
- Cannot share secrets between clusters without re-sealing
