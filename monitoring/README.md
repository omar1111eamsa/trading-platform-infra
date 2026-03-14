# Monitoring

Runtime monitoring for the test environment is deployed through the Ansible `monitoring` role.

Current stack:

- `Uptime Kuma` exposed on `frontend-vm:3001`

The compose definition rendered to the VM lives under:

- `/opt/monitoring/docker-compose.yml`
