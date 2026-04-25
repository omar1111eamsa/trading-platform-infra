#!/bin/bash
set -euo pipefail

PORTAINER_URL="${PORTAINER_URL:-https://127.0.0.1:9443}"
PORTAINER_USER="${PORTAINER_USER:-admin}"
PORTAINER_PASS="${PORTAINER_ADMIN_PASSWORD:?PORTAINER_ADMIN_PASSWORD is required}"
SYSTEM_REPO="${SYSTEM_REPO:-https://github.com/Trading-Terminal2025/SysteM}"
SYSTEM_REF="${SYSTEM_REF:-refs/heads/new-infra}"
SYSTEM_REPO_TOKEN="${SYSTEM_REPO_TOKEN:?SYSTEM_REPO_TOKEN is required}"
# Use dedicated GITHUB_TOKEN if provided, otherwise reuse SYSTEM_REPO_TOKEN for Portainer Git auth.
GITHUB_TOKEN="${GITHUB_TOKEN:-${SYSTEM_REPO_TOKEN}}"

ORG="${ORG:-Trading-Terminal2025}"
TARGET_REPOS="${TARGET_REPOS:-stable-backend- UI-Terminal- terminal-dashboard}"
CLEAN_LEGACY_SECRETS="${CLEAN_LEGACY_SECRETS:-false}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}

require_cmd curl
require_cmd python3
require_cmd gh

gh auth status >/dev/null 2>&1 || {
  echo "gh is not authenticated. Run: gh auth login" >&2
  exit 1
}

portainer_api() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  if [ -n "$body" ]; then
    curl -sk -X "$method" "${PORTAINER_URL}${path}" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -d "$body"
  else
    curl -sk -X "$method" "${PORTAINER_URL}${path}" \
      -H "Authorization: Bearer ${TOKEN}"
  fi
}

TOKEN=$(curl -sk -X POST "${PORTAINER_URL}/api/auth" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"${PORTAINER_USER}\",\"password\":\"${PORTAINER_PASS}\"}" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["jwt"])')

ENV_ID=$(curl -sk "${PORTAINER_URL}/api/endpoints" \
  -H "Authorization: Bearer ${TOKEN}" \
  | python3 -c 'import sys,json; data=json.load(sys.stdin); print(data[0]["Id"])')

echo "Authenticated with Portainer, endpoint=${ENV_ID}"

STACKS_JSON="$(portainer_api GET "/api/stacks")"

get_stack_id_by_name() {
  local stack_name="$1"
  python3 -c '
import json,sys
name=sys.argv[1]
endpoint_id=int(sys.argv[2])
items=json.load(sys.stdin)
for s in items:
    if s.get("Name")==name and int(s.get("EndpointId", -1))==endpoint_id:
        print(s.get("Id",""))
        break
' "$stack_name" "$ENV_ID" <<<"$STACKS_JSON"
}

create_stack() {
  local stack_name="$1"
  local file_path="$2"
  local interval="$3"
  local payload
  payload=$(cat <<JSON
{
  "name": "${stack_name}",
  "repositoryURL": "${SYSTEM_REPO}",
  "repositoryReferenceName": "${SYSTEM_REF}",
  "filePathInRepository": "${file_path}",
  "repositoryAuthentication": true,
  "repositoryUsername": "ci-bot",
  "repositoryPassword": "${GITHUB_TOKEN}",
  "autoUpdate": {
    "interval": "${interval}",
    "webhook": ""
  },
  "endpointId": ${ENV_ID}
}
JSON
)
  portainer_api POST "/api/stacks/create/standalone/repository" "$payload"
}

INFRA_ID="$(get_stack_id_by_name "trading-infra")"
if [ -z "$INFRA_ID" ]; then
  create_stack "trading-infra" "stacks/infra/docker-compose.yml" "5m" >/dev/null
  STACKS_JSON="$(portainer_api GET "/api/stacks")"
  INFRA_ID="$(get_stack_id_by_name "trading-infra")"
  echo "Created stack: trading-infra (id=${INFRA_ID})"
else
  echo "Stack already exists: trading-infra (id=${INFRA_ID})"
fi

APPS_ID="$(get_stack_id_by_name "trading-apps")"
if [ -z "$APPS_ID" ]; then
  create_stack "trading-apps" "stacks/apps/docker-compose.yml" "1m" >/dev/null
  STACKS_JSON="$(portainer_api GET "/api/stacks")"
  APPS_ID="$(get_stack_id_by_name "trading-apps")"
  echo "Created stack: trading-apps (id=${APPS_ID})"
else
  echo "Stack already exists: trading-apps (id=${APPS_ID})"
fi

APPS_STACK_JSON="$(portainer_api GET "/api/stacks/${APPS_ID}?endpointId=${ENV_ID}")"
WEBHOOK_ID="$(python3 -c 'import sys,json; s=json.load(sys.stdin); print((s.get("AutoUpdate") or {}).get("Webhook",""))' <<<"$APPS_STACK_JSON")"

if [ -z "$WEBHOOK_ID" ]; then
  echo "Could not resolve trading-apps webhook ID from Portainer API response." >&2
  exit 1
fi

PORTAINER_WEBHOOK_URL="${PORTAINER_URL}/api/webhooks/${WEBHOOK_ID}"
echo "Portainer apps webhook: ${PORTAINER_WEBHOOK_URL}"

for repo in ${TARGET_REPOS}; do
  repo_full="${ORG}/${repo}"
  echo "Updating GitHub secrets in ${repo_full}"
  gh secret set SYSTEM_REPO_TOKEN --repo "${repo_full}" --body "${SYSTEM_REPO_TOKEN}"
  gh secret set PORTAINER_WEBHOOK_URL --repo "${repo_full}" --body "${PORTAINER_WEBHOOK_URL}"
done

if [ "$CLEAN_LEGACY_SECRETS" = "true" ]; then
  delete_secret_if_exists() {
    local repo_full="$1"
    local secret_name="$2"
    if gh secret list --repo "$repo_full" | awk '{print $1}' | grep -qx "$secret_name"; then
      gh secret delete "$secret_name" --repo "$repo_full"
      echo "Deleted ${secret_name} from ${repo_full}"
    fi
  }

  for repo in ${TARGET_REPOS}; do
    repo_full="${ORG}/${repo}"
    delete_secret_if_exists "$repo_full" "GHCR_PULL_TOKEN"
    delete_secret_if_exists "$repo_full" "GHCR_PULL_USER"
  done

  delete_secret_if_exists "${ORG}/stable-backend-" "BACKEND_APP_DIR"
  delete_secret_if_exists "${ORG}/stable-backend-" "BACKEND_DOTENV"
  delete_secret_if_exists "${ORG}/UI-Terminal-" "UI_TERMINAL_APP_DIR"
  delete_secret_if_exists "${ORG}/terminal-dashboard" "DASHBOARD_APP_DIR"
fi

echo "GitOps bootstrap complete."
