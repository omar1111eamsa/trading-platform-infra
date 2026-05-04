# ADR 001 — k3s over Docker Swarm

## Status
Accepted

## Context
We needed a container orchestrator for the trading platform.
Options considered: Docker Swarm, k3s, full Kubernetes.

## Decision
We chose k3s.

## Reasons
- Docker Swarm is in maintenance mode with a shrinking ecosystem
- Full Kubernetes requires too many resources for a single VPS
- k3s runs on 1GB RAM, single binary, boots in seconds
- k3s is production-grade Kubernetes — same APIs, same tooling
- GitOps tooling (ArgoCD) is built around Kubernetes
- Easy to add nodes later for HA without architecture change

## Consequences
- Team needs basic kubectl knowledge
- Slightly more complex than Docker Compose for local dev
- Local dev still uses Docker Compose
