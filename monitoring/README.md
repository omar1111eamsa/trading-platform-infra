# Monitoring

Runtime monitoring for the OVH environment is deployed through the Ansible `monitoring` role.

## Current Stack

- `Uptime Kuma` is exposed on the VPS on port `3001`
- service compose file path: `/opt/monitoring/docker-compose.yml`

Current host:
- `REDACTED_VPS_IP`

## Suggested Monitors

Public checks:
- `https://terminal.example.com`
- `https://api.example.com/health` (keyword: `healthy`)
- `https://dashboard.example.com`

Internal checks (from Uptime Kuma on the same host):
- PostgreSQL: `127.0.0.1:5432` (TCP)
- RabbitMQ: `127.0.0.1:5672` (TCP)
- InfluxDB: `http://127.0.0.1:8086/ping`

Notes:
- all public monitors should use HTTPS
- if port `3001` is not publicly open, access Uptime Kuma using SSH tunnel
