# trading-platform-infra

Infrastructure and GitOps for a multi-service trading platform. This repository
is the single place from which the whole environment is provisioned, configured
and deployed: the server, the Kubernetes cluster, every supporting service
(databases, message broker, monitoring), and the application workloads
themselves.

It does not contain application source code. The four application services live
in their own repositories and are built by their own pipelines; what lives here
is everything needed to take a bare machine and turn it into a running platform,
plus the desired state that keeps it running.

## Why this repository exists

The platform started as a set of services that were deployed by hand. That
worked for one or two services and stopped working the moment there were six of
them talking to each other, plus a database, a broker, a metrics stack and TLS
to manage. Every deployment was a sequence of remembered SSH commands, and
nobody could reproduce the environment from scratch without the person who
originally set it up.

The goal of this repository was to remove that dependency entirely. Three things
drove the design:

**Portability.** The environment had to be reproducible from nothing. If the
server is lost, or a second one is needed, or the whole thing has to move to a
different provider, that should be a known procedure and not an archaeology
project. Provisioning is Terraform, machine setup is Ansible, and the cluster
state is Git. There is no manual step that exists only in someone's head. The
Terraform layer is split per provider (`terraform/ovh`, `terraform/azure`) so
moving or duplicating the platform onto different infrastructure is a matter of
a new provider directory, not a rewrite.

**Two environments, same definition.** Development and production are described
the same way, from the same manifests, so that what is tested is what ships. The
GitOps layout under `gitops/apps` is organised per environment (`staging` today,
with the same structure intended for production) reading from the same
infrastructure definitions in `gitops/infra`. The difference between
environments is configuration and image tags, not a different deployment method.

**Deployment time and effort.** A deploy should not be a careful manual ritual.
Once this is in place, shipping a change means a service pipeline pushes an image
and writes the new tag into this repository; ArgoCD notices the change and rolls
it out. A human rarely touches the cluster. The day-to-day operations that do
need a person are reduced to a small set of `make` targets rather than long
command sequences, so the knowledge required to operate the platform is in the
repository, not in tribal memory.

## How it is structured

```
terraform/      Provisioning: VPS and DNS, split per cloud provider
ansible/        Machine bootstrap: installs k3s and the cluster bootstrap layer
gitops/         Desired state for ArgoCD: infrastructure services and applications
docs/           Architecture notes, decision records, and operational runbooks
Makefile        The command interface for setup, validation and planning
```

The three layers map to three stages of bringing the platform up:

1. **Terraform** creates the server and the DNS records. State and providers are
   under `terraform/ovh` (OVH is the current host) with `terraform/azure` kept as
   a parallel target so the platform is not tied to a single vendor.

2. **Ansible** takes the provisioned machine and makes it a cluster. The roles
   under `ansible/roles` install k3s and bootstrap the pieces that must exist
   before GitOps can take over: the ingress controller, cert-manager, sealed
   secrets, monitoring and the runtime security agent. The playbooks
   (`site.yml`, `k3s.yml`, `argocd.yml`) run these in order.

3. **ArgoCD** then owns everything else. `gitops/argocd` defines the
   app-of-apps; `gitops/infra` holds the stateful and platform services
   (PostgreSQL, ClickHouse, RabbitMQ, monitoring, ingress, cert-manager, sealed
   secrets, Falco); `gitops/apps` holds the application deployments. From this
   point on, the cluster reconciles itself against what is committed here.

## What runs on the platform

The applications are six services across the trading system: the backend API,
the order/risk management service, the MT5 bridge, the market-data bridge, the
trader terminal, and the admin dashboard. They are supported by PostgreSQL as
the primary database, ClickHouse for market time-series and chart history,
RabbitMQ as the message broker between services, and Redis as a short-lived
cache.

Around the applications sit the platform services that make it operable in the
open: Nginx ingress with cert-manager and Let's Encrypt for TLS, Prometheus and
Grafana for metrics, Loki for logs, Falco for runtime security, and Sealed
Secrets so that credentials can live in Git in encrypted form without ever
exposing the plaintext.

The reasoning behind the larger choices — k3s rather than a heavier
orchestrator, ArgoCD for GitOps, ClickHouse over InfluxDB for the chart store, a
Go monorepo for the backend, sealed secrets for credential handling — is written
down in `docs/decisions`, one record per decision.

## Working with it

The repository is meant to be self-describing. To set up the local tooling
(pre-commit hooks, secret scanning, formatting checks):

```
make setup
```

To validate changes before they are committed — Terraform formatting and
validation, plus YAML linting across the GitOps tree:

```
make validate
```

To preview infrastructure changes:

```
make plan
```

Operational procedures that are not a single command — bringing the platform up
from scratch, rotating secrets, rolling back a release, reading the monitoring —
are documented as runbooks in `docs/runbooks` so they can be followed by anyone,
not only whoever wrote them.

## Room to grow

The structure is deliberately open-ended. Adding a new application service is a
new directory under `gitops/apps` and an entry in the app-of-apps; the rest of
the pipeline picks it up without further wiring. Adding a new piece of
infrastructure is the same pattern under `gitops/infra`. Moving to a second
server, a second environment, or a different cloud is a new Terraform target and
the same Ansible roles, because nothing above the provisioning layer assumes
where it runs.

It is a single-node cluster today because that is what the platform needs now.
Nothing in the design prevents it from becoming multi-node, multi-environment or
multi-region — those are additions to the existing layers rather than a different
approach. The point of building it this way was to make that growth boring.

## A note on secrets

Anything sensitive in this repository is either a Sealed Secret (encrypted, only
decryptable by the cluster's controller) or a reference to a value supplied at
deploy time. No plaintext credentials, server addresses, or private endpoints
are committed. The pre-commit configuration includes secret scanning to keep it
that way.
