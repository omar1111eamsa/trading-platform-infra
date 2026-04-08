# MT5 Worker Scaling Design

This document describes the target scaling model for MT5 workers. It is design-only and does not imply any live Terraform apply or VM mutation.

## Goal

Support session-driven MT5 capacity growth without treating the currently configured `windows-vm` and `windows-vm-2` as disposable infrastructure.

The desired steady-state architecture is:

- `linux_ui` / `trading-platform-vm-ui`: terminal UI and monitoring entrypoint (same OVH VPS as API)
- `linux_api` / `trading-platform-vm-api`: backend API, RabbitMQ, OMS, bridge (OVH VPS host)
- `mt5-worker-*`: future Windows worker pool used to host MT5 instances

The existing Windows hosts remain outside destructive infrastructure management:

- `windows-vm`: current manual MT5 host
- `windows-vm-2`: current manual clone / standby host

Future workers should be created from the `mt5-worker-golden` image family and managed as a separate worker pool.

## Core Principle

Scaling must be based on **free MT5 session slots**, not raw CPU or RAM metrics.

Example baseline:

- `max_sessions_per_worker = 7`

If one worker reaches 7 active sessions, new sessions must be assigned to another ready worker. If no worker has capacity, the system should provision another worker and hold the session as pending until the worker becomes ready.

## Recommended Phases

### Phase 1: Existing Workers Only

Use already-created Windows workers only.

- register `windows-vm` and `windows-vm-2` as workers
- assign sessions across them by capacity
- do not auto-create VMs yet

This is the safest first step because it validates the session allocator without mixing infrastructure automation into the critical path.

### Phase 2: Worker Pool Provisioning

Introduce worker provisioning from the golden image.

- provision `mt5-worker-*` from `mt5-worker-golden`
- wait for the worker to become healthy
- register it in the backend worker registry
- allow the allocator to assign sessions there

### Phase 3: Automatic Scale Down

Once worker lifecycle is stable:

- mark idle workers as `draining`
- stop assigning new sessions to them
- when session count reaches zero, stop or delete the worker

Delete should be the final action, not the first. A stop/start lifecycle is usually safer before full deletion.

## Target Control Plane

The platform needs three distinct layers.

### 1. Session Allocator

Responsible for deciding which worker gets a new session.

Inputs:

- worker health
- current used slots
- max slots
- worker state

Output:

- `session_id -> worker_id` assignment

### 2. Worker Pool Manager

Responsible for VM capacity management.

Responsibilities:

- create new workers from the golden image
- start stopped workers
- mark workers as draining
- stop or delete idle workers

### 3. Worker Agent

Runs on each Windows worker and is responsible for local MT5 process lifecycle.

Responsibilities:

- start an MT5 instance for an assigned session
- track slot usage
- report `ready`, `busy`, `offline`, `error`
- report per-session startup success/failure

The worker agent is the bridge between infrastructure capacity and MT5 process orchestration.

## Worker Registry Model

The backend should persist worker state in dedicated records.

Suggested model:

### `mt5_workers`

- `worker_id`
- `vm_name`
- `internal_ip`
- `external_ip`
- `state` (`ready`, `busy`, `draining`, `offline`, `provisioning`)
- `max_sessions`
- `used_sessions`
- `image_family`
- `created_at`
- `last_heartbeat_at`

### `session_assignments`

- `session_id`
- `worker_id`
- `slot_index`
- `assignment_state` (`reserved`, `starting`, `active`, `failed`, `released`)
- `created_at`

## Allocation Rules

Recommended first rule set:

1. only allocate to workers in `ready` or `busy`
2. ignore workers in `draining`, `offline`, or `provisioning`
3. choose the worker with the lowest `used_sessions` that still has capacity
4. reserve the slot before starting MT5
5. if no capacity exists, mark the session `pending_worker_capacity`

Example with `max_sessions_per_worker = 7`:

- sessions `1..7` -> worker 1
- sessions `8..14` -> worker 2
- sessions `15..21` -> worker 3

For `16` sessions, the distribution should be:

- worker 1: `7`
- worker 2: `7`
- worker 3: `2`

## Scale-Up Rules

Recommended policy:

- `min_ready_workers = 1`
- `max_sessions_per_worker = 7`
- `scale_up_when_free_slots_lt = 2`

Meaning:

- if total free slots across ready workers drops below `2`, provision another worker

This avoids waiting until capacity is already exhausted.

## Scale-Down Rules

Recommended policy:

- only scale down workers with `used_sessions = 0`
- first change worker state to `draining`
- wait for all assigned sessions to end
- after idle timeout, stop the worker
- after longer idle timeout, optionally delete the worker

Suggested timers:

- stop after `30-60` minutes idle
- delete after `12-24` hours idle if cost pressure requires it

## Why Not Terraform Alone

Terraform is appropriate for:

- base worker model
- image references
- firewall/tag conventions
- static infrastructure definitions

Terraform is not the right runtime control loop for:

- create-on-demand during user session flow
- slot-based scale decisions
- rapid stop/start/delete logic

Runtime scaling should be driven by an application-side worker pool manager using the chosen cloud provider APIs, not by repeated manual `terraform apply`.

## Golden Image Strategy

Future workers should come from:

- image family: `mt5-worker-golden`

Golden image lifecycle:

1. configure a known-good Windows MT5 VM
2. snapshot it
3. create/update the `mt5-worker-golden` image family
4. launch future workers from that family

This keeps future worker creation reproducible while preserving the existing manual Windows hosts.

## Non-Goals For Current Step

This design does **not** require:

- deleting `windows-vm`
- deleting `windows-vm-2`
- applying Terraform immediately
- auto-scaling implementation in the backend today

This design is only the target operating model for the next implementation steps.
