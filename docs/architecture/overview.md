# Architecture Overview

## Platform Summary

App Capital is a trading platform composed of four repositories
deployed on a single OVH VPS running k3s.

## Repository Map

| Repo | Purpose |
|---|---|
| `SysteM` | Infrastructure, GitOps, Ansible, Terraform |
| `stable-backend-` | Go monorepo — backend-api, oms-rms, mt5-bridge, market-data-bridge |
| `UI-Terminal-` | Next.js trader-facing terminal |
| `terminal-dashboard` | React/Vite admin dashboard |

## Infrastructure Stack

| Component | Tool |
|---|---|
| Orchestration | k3s |
| GitOps | ArgoCD |
| Ingress | Nginx Ingress Controller |
| SSL | cert-manager + Let's Encrypt |
| Secrets | Sealed Secrets |
| Metrics | Prometheus + Grafana |
| Logs | Loki + Promtail |
| Runtime security | Falco |
| DNS | OVH (managed via Terraform) |
| VM bootstrap | Ansible |

## Application Stack

| Component | Technology |
|---|---|
| Backend API | Go, PostgreSQL, RabbitMQ |
| Order Management | Go, RabbitMQ |
| MT5 Bridge | Go, TCP :5556 |
| Market Data Bridge | Go, ClickHouse |
| Chart store | ClickHouse |
| Message broker | RabbitMQ |
| Primary database | PostgreSQL (CloudNativePG) |
| Frontend terminal | Next.js 14, TypeScript |
| Admin dashboard | React, Vite, TypeScript |

## Network Architecture

```
Internet
    ↓
OVH VPS (REDACTED_VPS_IP)
    ↓
Nginx Ingress (ports 80/443)
    ↓
cert-manager (SSL termination)
    ├── api.example.com          → backend-api:8081
    ├── terminal.example.com     → ui-terminal:3000
    ├── dashboard.example.com    → terminal-dashboard:80
    ├── argocd.example.com       → argocd-server:80
    └── grafana.example.com      → grafana:3000
```

## Cluster Namespaces

| Namespace | Contents |
|---|---|
| `argocd` | ArgoCD server and controllers |
| `infra` | postgres, rabbitmq, clickhouse |
| `monitoring` | prometheus, grafana, loki, falco |
| `staging` | all app services (served on production domains) |

## Internal Service Communication

```
ui-terminal
    → backend-api:8081 (REST + WebSocket)

terminal-dashboard
    → backend-api:8081 (REST)

backend-api
    → postgres.infra:5432
    → rabbitmq.infra:5672
    → clickhouse.infra:9000

oms-rms
    → rabbitmq.infra:5672
    → backend-api:8081

mt5-bridge
    → rabbitmq.infra:5672
    → MT5 EA (external TCP :5556)

market-data-bridge
    → rabbitmq.infra:5672
    → clickhouse.infra:9000
```
