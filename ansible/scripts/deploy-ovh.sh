#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NEW_SCRIPT="$ROOT_DIR/scripts/deploy.sh"
OVH_INV="$ROOT_DIR/inventories/ovh/hosts.yml"

if [[ ! -x "$NEW_SCRIPT" ]]; then
  echo "Missing script: $NEW_SCRIPT"
  exit 1
fi

echo "deploy-ovh.sh is deprecated. Use scripts/deploy.sh instead."

has_inventory_arg=false
for arg in "$@"; do
  if [[ "$arg" == "-i" || "$arg" == "--inventory" ]]; then
    has_inventory_arg=true
    break
  fi
done

if [[ "$has_inventory_arg" == "true" ]]; then
  exec "$NEW_SCRIPT" "$@"
else
  exec "$NEW_SCRIPT" -i "$OVH_INV" "$@"
fi
