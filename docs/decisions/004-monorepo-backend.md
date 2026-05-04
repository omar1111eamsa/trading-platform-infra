# ADR 004 — Monorepo for backend services

## Status
Accepted

## Context
Three backend services: backend-api, oms-rms, mt5-bridge.
Decision: monorepo vs separate repos.

## Decision
Keep all backend services in one monorepo (stable-backend-).

## Reasons
- Services are tightly coupled via RabbitMQ message contracts
- Shared data models and types
- Cross-service changes can be made atomically in one PR
- Small team — one repo is easier to navigate
- CI already handles building only changed services

## Consequences
- One bad commit can block CI for all services
- Ownership is shared across the backend team
- Separate repos for frontends (UI-Terminal-, terminal-dashboard)
  since they are independent and have different release cycles
