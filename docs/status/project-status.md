# Project Status

This document tracks the work completed so far, known constraints, and the next recommended actions.

## Completed

### CI/CD and Images

- moved frontend and backend deployment from VM-local builds to CI-built container images
- pushed application images to GHCR with commit-based tags
- updated deploy jobs to pull images from GHCR on the target VMs
- added OCI metadata labels for image traceability
- enabled Buildx container driver for image builds
- optimized backend builds by parallelizing image creation
- optimized frontend builds by reusing the built `dist/` artifact instead of rebuilding inside the image job

### Deploy Safety

- added explicit rollback workflows for backend and frontend
- validated rollback logic manually on the VMs by pulling `test-ci-latest` images and recreating containers
- added stronger deploy smoke tests:
  - backend checks `/health`
  - backend checks unauthenticated API behavior
  - backend supports authenticated smoke checks if smoke-test secrets are provided
  - frontend checks HTML plus main JS asset delivery

### Registry Hygiene

- added GHCR cleanup workflows for backend and frontend packages
- kept the cleanup cadence on weekly schedule after the temporary test schedule was reverted

### Infrastructure Modeling

- updated `SysteM` to model:
  - `trading-platform-vm-ui` (Ansible `linux_ui`)
  - `trading-platform-vm-api` (Ansible `linux_api`)
  - `trading-platform-vm-dashboard` (Ansible `linux_dashboard`)
  - future `mt5-worker-*` VMs
- kept current `windows-vm` and `windows-vm-2` outside destructive infrastructure management
- added future worker variables, outputs, and image-based worker creation model
- added a minimal Ansible `worker.yml` playbook as a placeholder for future worker handling

### Golden Image

- created snapshot:
  - `mt5-worker-golden-20260322-snap`
- created image:
  - `mt5-worker-golden-20260322`
- image family:
  - `mt5-worker-golden`

### OVH Migration

- moved the live Linux host to an OVH VPS (`REDACTED_VPS_IP`)
- configured SSL/TLS via Let's Encrypt (Certbot) on nginx
- all public endpoints now served over HTTPS with no exposed port numbers
- domains live: `api.example.com`, `terminal.example.com`, `dashboard.example.com`
- nginx reverse proxy terminates TLS and forwards to local services

### CI/CD on OVH

- self-hosted GitHub runners (`trading-platform-vm-ui`, `trading-platform-vm-api`, `trading-platform-vm-dashboard`) operational on the OVH VPS
- removed `assert-runner-online` job from CI workflows
- updated smoke tests with retry logic for more reliable post-deploy verification
- made authenticated smoke tests non-fatal (CI passes even if smoke-test secrets are absent)
- deploy branch: `test-ci`

### Documentation and Design

- documented MT5 worker scaling design
- updated infrastructure docs to reflect OVH VPS architecture, HTTPS, and current IP/domain layout

## Current Known Constraints

### VPS Memory

- current OVH VPS plan determines the available RAM; all Docker services share this host
- containers are memory-constrained; OOM kills are possible under sustained load
- upgrade the VPS plan if memory pressure persists

### GitHub Workflow Visibility on `test-ci`

- some workflows added only on `test-ci` are not visible or dispatchable in GitHub Actions UI/API
- this affected:
  - rollback workflow visibility
  - scheduled GHCR cleanup workflow visibility
- rollback logic itself is valid, but GitHub branch/default-branch workflow visibility is still a constraint

### Optional Smoke-Test Secrets

- authenticated backend smoke testing is only fully active if these repo secrets exist:
  - `BACKEND_SMOKE_USERNAME`
  - `BACKEND_SMOKE_PASSWORD`

### Local `SysteM` Cleanup Debt

- local/untracked helper files still exist in the workspace and are not part of the committed infrastructure state
- periodically review and remove stale generated local files (`.terraform`, `.venv`, state backups) when not needed

## Recommended Next Actions

### Deployment / Operations

1. add `BACKEND_SMOKE_USERNAME` and `BACKEND_SMOKE_PASSWORD` repo secrets for full authenticated smoke tests
2. decide whether branch-only workflows should remain on `test-ci` or be promoted to the default branch for GitHub visibility
3. review Docker Compose resource limits — current values may exceed what 2 GB RAM can safely support under load
4. plan VPS upgrade if memory pressure persists

### Platform / Backend

1. add worker registry in backend
2. add session-to-worker assignment model
3. add Windows worker agent for MT5 process lifecycle
4. later add worker pool manager for automatic scale-up / scale-down

## Explicitly Not Done Yet

- no Terraform apply was performed for the new worker model
- no existing Windows VM was deleted or recreated
- no live worker autoscaling was implemented
- no backend orchestration layer was added yet
