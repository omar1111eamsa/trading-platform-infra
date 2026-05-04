# Bootstrap Runbook

How to bring up the full platform from scratch.

## Prerequisites

- OVH VPS running Ubuntu 22.04
- SSH access to VPS
- GitHub org with all repos
- OVH API credentials
- Domain example.com pointing to VPS IP

## Step 1 — DNS

```bash
cd terraform/ovh
cp terraform.tfvars.example terraform.tfvars
# fill in your OVH API credentials
vim terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Step 2 — Bootstrap VPS

```bash
cd ansible
cp inventories/ovh/group_vars/secrets.yml.example \
   inventories/ovh/group_vars/secrets.yml
# fill in secrets
vim inventories/ovh/group_vars/secrets.yml
ansible-vault encrypt inventories/ovh/group_vars/secrets.yml
ansible-galaxy collection install -r collections/requirements.yml
ansible-playbook playbooks/site.yml --ask-vault-pass
```

This installs in order:
1. Common OS hardening
2. k3s
3. Helm + repos
4. Nginx Ingress
5. cert-manager + ClusterIssuers
6. Sealed Secrets
7. ArgoCD
8. Monitoring (Prometheus + Grafana + Loki)
9. Falco

## Step 3 — Connect ArgoCD to SysteM repo

```bash
# Get ArgoCD initial password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Login to ArgoCD UI
# https://argocd.example.com
# user: admin
# pass: (from above)

# Add SysteM repo in ArgoCD UI
# Settings → Repositories → Connect Repo
# URL: https://github.com/trading-platform/SysteM
# Use GITOPS_TOKEN for auth
```

## Step 4 — Create Sealed Secrets

```bash
# For each service, follow instructions in the sealedsecret.yaml comments
# Example for backend-api staging:
kubectl create secret generic backend-api-secrets \
  --namespace staging \
  --from-literal=PORT=8081 \
  --from-literal=POSTGRES_DSN=postgres://app:password@postgres.infra:5432/terminal_backend?sslmode=disable \
  --from-literal=JWT_SECRET=your_jwt_secret \
  --from-literal=RABBITMQ_URL=amqp://app:password@rabbitmq.infra:5672/ \
  --from-literal=CLICKHOUSE_DSN=clickhouse://default:password@clickhouse.infra:9000/app \
  --dry-run=client -o yaml | \
kubeseal --format yaml > gitops/apps/staging/backend-api/sealedsecret.yaml

git add gitops/apps/staging/backend-api/sealedsecret.yaml
git commit -m "feat(secrets): add backend-api staging sealed secret"
git push
```

## Step 5 — Trigger first deploy

```bash
# Push to staging branch in any app repo
# CI builds image, pushes to GHCR, updates gitops
# ArgoCD detects change and deploys
```

## Step 6 — Verify

```bash
# Check all pods running
kubectl get pods -A

# Check ArgoCD apps
kubectl get applications -n argocd

# Check ingress
kubectl get ingress -A

# Check certificates
kubectl get certificates -A

# Hit health endpoint
curl https://api.example.com/health
curl https://staging-api.example.com/health
```
