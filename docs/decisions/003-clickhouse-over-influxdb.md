# ADR 003 — ClickHouse over InfluxDB

## Status
Accepted

## Context
We needed a time-series store for trading candle data.
InfluxDB was the original choice.

## Decision
Replaced InfluxDB with ClickHouse for candle storage.

## Reasons
- ClickHouse handles high-throughput writes better at scale
- ReplacingMergeTree engine handles duplicate candle writes naturally
- SQL interface — easier to query and debug than InfluxQL/Flux
- Better compression for OHLCV data
- Single candles table with broker/symbol/timeframe partitioning
- InfluxDB free tier limitations

## Consequences
- InfluxDB removed from infra stack
- backend-api reads candles via CLICKHOUSE_DSN env var
- market-data-bridge writes directly to ClickHouse
- InfluxDB code still exists in codebase but is being phased out
