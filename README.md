# trading-platform-infra

Infrastructure and GitOps for a multi-service trading platform. One repository
that takes a bare server and turns it into a running platform: provisioning, the
Kubernetes cluster, the databases and message broker, monitoring, TLS, and the
application deployments themselves.

No application source code lives here. The six services are built in their own
repositories; this repo holds everything needed to deploy and operate them, plus
the desired state that keeps the cluster matching Git.

```
                              Internet
                                 |
                         Nginx Ingress (80/443)
                      cert-manager + Let's Encrypt (TLS)
                                 |
         +-----------+-----------+-----------+-----------+
         |           |           |           |           |
     backend-api  terminal   dashboard    argocd     grafana
         |
   +-----+-----+-----------+-----------+
   |     |     |           |           |
 oms-rms mt5  market-data  ...   (application layer)
         bridge  bridge
         |
   +-----+----------+-------------+----------+
   |                |             |          |
 PostgreSQL     ClickHouse     RabbitMQ    Redis
 (primary db)   (market data)  (broker)   (cache)
```

## The problem this solves

The platform began as services deployed by hand. That held for one or two
services and broke the moment there were six of them, plus a database, a broker,
a metrics stack and TLS to manage. Every deploy was a sequence of remembered SSH
commands, and the environment could not be rebuilt without the person who first
set it up.

There was a second problem on the development side. Each developer ran services
locally with no shared, integrated environment, so work that depended on other
services was hard: there was nowhere that all the pieces ran together against the
same databases and broker. This repository also fixes that by providing a real
staging environment that mirrors production, so developers integrate against the
running system instead of stubs on their own machine.

This repository removes both dependencies. The whole platform is defined as code,
in three layers, so it can be rebuilt from nothing and operated from a handful of
commands instead of memory.

## Design goals

| Goal | How it is met |
|---|---|
| **Portable** — rebuildable from zero, not tied to one server or vendor | Terraform provisions, Ansible bootstraps, Git holds cluster state. No manual step lives only in someone's head. Terraform is split per provider so a new cloud target is a new directory, not a rewrite. |
| **Two environments, one definition** — what is tested is what ships | `gitops/apps` is organised per environment from the same `gitops/infra` base. Environments differ by config and image tag, not by deployment method. |
| **Fast, low-effort deploys** — no manual ritual | A service pipeline pushes an image and writes the tag here; ArgoCD rolls it out. Humans rarely touch the cluster. |
| **Expandable** — growth is additive, not a rewrite | New service = a directory plus an app-of-apps entry. New infra = same pattern. New cloud = a new Terraform target. |

## Deployment flow

```
git push  ->  CI builds & pushes image  ->  CI writes new tag into this repo
                                                       |
                                          ArgoCD detects the change
                                                       |
                                          rolling update on the cluster
```

A code change reaches production without anyone running a deploy command by hand.

## Repository layout

```
terraform/   Provisioning: VPS and DNS, split per cloud provider
ansible/     Machine bootstrap: k3s + the pre-GitOps cluster layer
gitops/      Desired state for ArgoCD: infra services and applications
docs/        Architecture notes, decision records, runbooks
Makefile     Command interface: setup, validate, plan
```

Bringing the platform up is three stages, each owning the next:

1. **Terraform** creates the server and DNS records (`terraform/ovh`). An Azure
   target previously provisioned Windows machines to run applications that need
   Windows, such as the MT5 trader; it has since been removed because those
   workloads now run on the organisation's own servers. The per-provider split
   remains the pattern, so a cloud target can be added back the same way.
2. **Ansible** turns the machine into a cluster — installs k3s and the pieces
   that must exist before GitOps takes over (ingress, cert-manager, sealed
   secrets, monitoring, runtime security). Playbooks: `site.yml`, `k3s.yml`,
   `argocd.yml`.
3. **ArgoCD** owns everything after that. `gitops/argocd` is the app-of-apps,
   `gitops/infra` the platform services, `gitops/apps` the application
   deployments. The cluster then reconciles itself against this repo.

## What runs on it

Applications (six services, deployed from `gitops/apps`):

| Service | Role |
|---|---|
| backend-api | REST API, talks to PostgreSQL and RabbitMQ |
| oms-rms | Order and risk management |
| mt5-bridge | Bridge to MetaTrader 5 over TCP |
| market-data-bridge | Tick and candle ingestion into ClickHouse |
| ui-terminal | Trader-facing terminal (Next.js) |
| terminal-dashboard | Admin dashboard (React/Vite) |

Data and platform services (`gitops/infra`):

| Component | Tool | Purpose |
|---|---|---|
| Database | PostgreSQL | Primary transactional store |
| Market data | ClickHouse | Tick and candle time-series, chart history |
| Broker | RabbitMQ | Messaging between services |
| Cache | Redis | Short-lived tick cache |
| Ingress / TLS | Nginx + cert-manager | Routing and Let's Encrypt certificates |
| Metrics | Prometheus + Grafana | Monitoring and alerting |
| Logs | Loki | Log aggregation |
| Runtime security | Falco | Syscall-level threat detection |
| Secrets | Sealed Secrets | Encrypted credentials safe to keep in Git |

Routing is handled by the Nginx ingress today. The plan is to move the edge to a
dedicated API gateway, which would centralise authentication, rate limiting and
routing in one place ahead of the services rather than spreading that concern
across ingress rules. The current setup is structured so this is a swap at the
edge, not a change to the services behind it.

The reasoning behind the larger choices — k3s over a heavier orchestrator,
ArgoCD for GitOps, ClickHouse over InfluxDB, sealed secrets for credentials — is
recorded in `docs/decisions`, one file per decision.

## Operating it

```
make setup      # local tooling: pre-commit hooks, secret scanning, linters
make validate   # terraform fmt/validate + yamllint across gitops/
make plan       # preview infrastructure changes
```

Procedures that need a human — first-time bootstrap, secret rotation, rollback,
reading the monitoring — are written as runbooks in `docs/runbooks`, so they can
be followed by anyone, not only whoever wrote them.

## Room to grow

It is a single-node cluster today because that is what the platform needs now.
Nothing in the design blocks it from going multi-node, multi-environment or
multi-region: those are additions to the existing layers, not a different
approach. Adding a service, a database, or a second cloud all follow patterns
that are already in the repo. The intent was to make that growth boring.

## Secrets

Credentials are stored as Sealed Secrets — encrypted in Git and decryptable only
by the controller running in the cluster. This was chosen for portability: the
secrets live in the same repository as everything else, so a rebuild pulls the
configuration and its secrets together, with no separate vault or out-of-band
step to restore. The encrypted form is safe to keep in a public repository
because the plaintext never leaves the cluster.

No plaintext credentials, server addresses, or private endpoints are committed,
and pre-commit secret scanning keeps it that way.
