# Monitoring Runbook

## Access

- Grafana: https://grafana.example.com
- ArgoCD: https://argocd.example.com

## Key dashboards

| Dashboard | What it shows |
|---|---|
| Kubernetes cluster | Node CPU, memory, disk |
| Pod metrics | Per-pod CPU, memory, restarts |
| Nginx Ingress | Request rate, latency, errors |
| PostgreSQL | Connections, query time, locks |
| RabbitMQ | Queue depth, message rate |
| ClickHouse | Query rate, storage |

## Alerts to set up in Grafana

| Alert | Condition |
|---|---|
| Pod crash looping | restarts > 5 in 10 minutes |
| High memory | pod memory > 90% of limit |
| API error rate | 5xx rate > 1% for 5 minutes |
| RabbitMQ queue depth | queue > 1000 messages |
| Disk usage | node disk > 80% |
| Certificate expiry | cert expires in < 14 days |

## Checking logs

```bash
# All logs for a service
kubectl logs -l app=backend-api -n staging --tail=100

# Follow logs
kubectl logs -l app=backend-api -n staging -f

# Loki via Grafana
# Explore → Loki → {namespace="staging", app="backend-api"}
```

## Checking pod health

```bash
# All pods
kubectl get pods -A

# Describe a failing pod
kubectl describe pod <pod-name> -n staging

# Get events
kubectl get events -n staging --sort-by='.lastTimestamp'
```
