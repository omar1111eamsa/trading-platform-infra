#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INV="$ROOT_DIR/inventories/ovh/hosts.yml"

if [[ ! -f "$INV" ]]; then
  echo "Missing inventory: $INV"
  exit 1
fi

cd "$ROOT_DIR"
ansible-galaxy collection install -r collections/requirements.yml
ansible-playbook -i "$INV" playbooks/site.yml "$@"
