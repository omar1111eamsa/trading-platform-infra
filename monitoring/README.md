# Monitoring

Runtime monitoring for the test environment is deployed through the Ansible `monitoring` role.

Current stack:

- `Uptime Kuma` exposed on `frontend-vm:3001`
- public URL: `http://REDACTED_IP:3001`

The compose definition rendered to the VM lives under:

- `/opt/monitoring/docker-compose.yml`

## Uptime Kuma Configuration Guide

To accurately monitor the system without exposing the databases publicly, setup your monitors in your dashboard identically to this:

### 🌍 PUBLIC Monitors (Testing the Firewalls + App)
1. **Frontend Dashboard:**
   - Type: `HTTP(s)`
   - URL: `http://REDACTED_IP:80`
2. **Backend API:**
   - Type: `HTTP(s) - Keyword`
   - URL: `http://api.example.com:8081/health`
   - Keyword: `healthy`

### 🔒 INTERNAL Monitors (Testing the isolated VPC network)
3. **PostgreSQL Database:**
   - Type: `TCP Port`
   - Hostname: `10.132.0.3`
   - Port: `5432`
4. **RabbitMQ Broker:**
   - Type: `TCP Port`
   - Hostname: `10.132.0.3`
   - Port: `5672`
5. **InfluxDB:**
   - Type: `HTTP(s)`
   - URL: `http://10.132.0.3:8086/ping`
6. **Windows MT5 Server:**
   - Type: `Ping`
   - Hostname: `10.132.0.4`
