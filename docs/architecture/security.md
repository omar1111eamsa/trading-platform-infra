# Security Architecture

## Layers

### Layer 1 — Developer machine
- pre-commit hooks (gitleaks, detect-secrets)
- go-fmt, eslint, type-check
- Blocks bad commits locally

### Layer 2 — CI pipeline
- Gitleaks (secret scanning)
- Semgrep (SAST)
- Gosec (Go security)
- Nancy (Go dependency audit)
- Trivy (Docker image scan)
- Blocks bad images from reaching GHCR

### Layer 3 — Container
- Distroless base images (no shell, no package manager)
- Non-root user (uid 1000 or nonroot)
- Read-only root filesystem
- All capabilities dropped

### Layer 4 — Kubernetes
- Network policies (service isolation)
- Pod security (no privilege escalation)
- Sealed Secrets (no plaintext secrets in git)
- Resource limits (no resource exhaustion)

### Layer 5 — Ingress
- Rate limiting on all endpoints
- Security headers (HSTS, CSP, X-Frame-Options)
- TLS 1.2+ only

### Layer 6 — Runtime
- Falco (detects unexpected behavior in containers)
- Alerts to Grafana on suspicious activity

## Secret Management

Secrets flow:
```
Developer creates secret locally
        ↓
kubeseal encrypts with cluster public key
        ↓
Encrypted SealedSecret committed to git
        ↓
ArgoCD applies SealedSecret to cluster
        ↓
Sealed Secrets controller decrypts
        ↓
Pod reads secret as environment variable
```

Never commit plaintext secrets.
Never put secrets in Docker images.
Never put secrets in environment variables in Dockerfiles.
