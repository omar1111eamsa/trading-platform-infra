# AWS Baseline Capture (Before WS/Table Refactor)

Captured on: 2026-04-26 (UTC)  
Environment: `api.test.example.com` / AWS VM `REDACTED_IP` / branch `new-infra`

## Scope

This baseline is the reference point before starting Workstream 1/2 (WS contract split + table delta refactor).

Metrics captured:
- HTTP API latency percentiles
- WebSocket connect/reconnect latency
- WebSocket payload sizes and message rate
- RabbitMQ queue depth snapshot and short drift
- Container CPU/memory snapshot

Not captured in this pass:
- Browser render latency (needs client-side instrumentation)
- Large concurrent synthetic load (50/100/250/500 users) and chaos tests (planned next)

## 1) API Latency Baseline (60 samples per endpoint)

Measured from inside AWS VM against public HTTPS endpoint.

### `GET /health`
- status: `200`
- payload avg: `556` bytes
- p50: `34.65 ms`
- p95: `62.80 ms`
- p99: `103.69 ms`

### `POST /auth/login`
- status: `200`
- payload avg: `541` bytes
- p50: `146.88 ms`
- p95: `214.43 ms`
- p99: `286.73 ms`

### `GET /api/sessions`
- status: `200`
- payload avg: `468` bytes
- p50: `37.46 ms`
- p95: `57.41 ms`
- p99: `81.87 ms`

### `GET /api/market-data/symbols?sessionId=FxPro_1`
- status: `200`
- payload avg: `6986` bytes
- p50: `40.61 ms`
- p95: `61.05 ms`
- p99: `73.21 ms`

### `GET /api/market-data/candles?sessionId=FxPro_1&symbol=BTCEUR&timeframe=M1&limit=200`
- status: `200`
- payload avg: `55480` bytes
- p50: `57.61 ms`
- p95: `81.80 ms`
- p99: `101.06 ms`

## 2) WebSocket Connect/Reconnect Baseline

Endpoint: `wss://api.test.example.com/ws/market`  
Session: `FxPro_1`

### Reconnect success (50 connect/disconnect iterations)
- attempts: `50`
- success: `50`
- success rate: `100.0%`
- handshake p50: `43.44 ms`
- handshake p95: `61.19 ms`
- connected p95: `88.25 ms`
- subscribed p95: `88.32 ms`
- first snapshot p95: `187.30 ms`
- first live message p95: `201.81 ms`

### Disconnect window replay/snapshot checks

All reconnects below succeeded with fresh subscription/snapshot delivery:

- after `5s` disconnect:
  - connected: `3.51 ms`
  - subscribed: `6.27 ms`
  - snapshot: `80.72 ms`
- after `30s` disconnect:
  - connected: `6.67 ms`
  - subscribed: `6.71 ms`
  - snapshot: `48.31 ms`
- after `300s` disconnect:
  - connected: `44.37 ms`
  - subscribed: `44.73 ms`
  - snapshot: `292.04 ms`

## 3) WebSocket Payload + Throughput (20s sample)

Session: `FxPro_1`, symbol `BTCEUR`, timeframe `M1`

- total messages: `563` in `20s`
- observed rate: `28.15 msg/s`
- payload p50: `497 bytes`
- payload p95: `498 bytes`
- payload p99: `498 bytes`
- payload max: `61935 bytes` (snapshot burst)

Message type counts:
- `connected`: `1`
- `subscribed`: `1`
- `snapshot`: `1`
- `history_candle`: `470`
- `table_update`: `90`

## 4) RabbitMQ Queue Depth Baseline

Queue snapshot (highlights):
- `q.mt5.candles`: `6637` (earlier sample), later sample up to `10391`
- `q.mt5.account_info`: `1`
- `q.oms.account_info`: `1` or `0`
- most command/confirm queues: `0`

60s drift sample:
- `q.mt5.candles`: `10391 -> 7595` (draining, no unbounded growth in this short window)

## 5) Container Resource Snapshot (`docker stats --no-stream`)

High CPU observed during capture window:
- `trading-infra-rabbitmq-1`: `70.12%`
- `trading-infra-influxdb-1`: `58.27%`
- `trading-infra-postgres-1`: `20.77%`
- `trading-apps-backend-api-1`: `20.63%`

Memory highlights:
- `rabbitmq`: `272.8 MiB / 1.5 GiB`
- `influxdb`: `85.82 MiB / 3 GiB`
- `backend-api`: `14.06 MiB / 2 GiB`
- `mt5-bridge`: `6.62 MiB / 1 GiB`

## 6) Immediate Observations (Before Refactor)

1. Core API and WS latencies are currently acceptable at low concurrency.
2. `q.mt5.candles` remains the dominant queue pressure point.
3. Snapshot payload can spike to ~62 KB; this validates the need for delta-first streams.
4. Reconnect behavior is currently good for single-session low-load tests, but still needs formal multi-user load + chaos validation.

## 7) Next Baseline Steps (Planned)

1. Run concurrent load profiles: `50/100/250/500` clients with mixed symbols/timeframes.
2. Capture p50/p95/p99 WS end-to-end update latency under burst.
3. Add browser render timing probes for table/chart paint latency.
4. Execute chaos scenarios: gateway restart, broker disconnect, jitter/loss simulation.
