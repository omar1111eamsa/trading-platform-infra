#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_INV="$ROOT_DIR/inventories/ovh/hosts.yml"

has_inventory_arg=false
for arg in "$@"; do
  if [[ "$arg" == "-i" || "$arg" == "--inventory" ]]; then
    has_inventory_arg=true
    break
  fi
done

INVENTORY_ARGS=()
if [[ "$has_inventory_arg" == "false" ]]; then
  if [[ ! -f "$DEFAULT_INV" ]]; then
    echo "Missing default inventory: $DEFAULT_INV"
    echo "Pass one explicitly with: -i inventories/<env>/hosts.yml"
    exit 1
  fi
  INVENTORY_ARGS=(-i "$DEFAULT_INV")
fi

cd "$ROOT_DIR"
ansible-galaxy collection install -r collections/requirements.yml
ansible-playbook "${INVENTORY_ARGS[@]}" playbooks/site.yml "$@"
