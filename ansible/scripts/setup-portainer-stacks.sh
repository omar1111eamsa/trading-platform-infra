#!/bin/bash
set -euo pipefail

PORTAINER_URL="https://127.0.0.1:9443"
PORTAINER_USER="admin"
PORTAINER_PASS="${PORTAINER_ADMIN_PASSWORD}"
GITHUB_TOKEN="${GITHUB_TOKEN}"
SYSTEM_REPO="https://github.com/Trading-Terminal2025/SysteM"
SYSTEM_REF="refs/heads/new-infra"

TOKEN=$(curl -sk -X POST "${PORTAINER_URL}/api/auth" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"${PORTAINER_USER}\",\"password\":\"${PORTAINER_PASS}\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['jwt'])")

echo "Authenticated with Portainer"

ENV_ID=$(curl -sk "${PORTAINER_URL}/api/endpoints" \
  -H "Authorization: Bearer ${TOKEN}" \
  | python3 -c "import sys,json; data=json.load(sys.stdin); print(data[0]['Id'])")

echo "Environment ID: ${ENV_ID}"

curl -sk -X POST "${PORTAINER_URL}/api/stacks/create/standalone/repository" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"trading-infra\",
    \"repositoryURL\": \"${SYSTEM_REPO}\",
    \"repositoryReferenceName\": \"${SYSTEM_REF}\",
    \"filePathInRepository\": \"stacks/infra/docker-compose.yml\",
    \"repositoryAuthentication\": true,
    \"repositoryUsername\": \"ci-bot\",
    \"repositoryPassword\": \"${GITHUB_TOKEN}\",
    \"autoUpdate\": {
      \"interval\": \"5m\",
      \"webhook\": \"\"
    },
    \"endpointId\": ${ENV_ID}
  }" | python3 -m json.tool

echo "Infra stack created"

APPS_RESPONSE=$(curl -sk -X POST \
  "${PORTAINER_URL}/api/stacks/create/standalone/repository" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"trading-apps\",
    \"repositoryURL\": \"${SYSTEM_REPO}\",
    \"repositoryReferenceName\": \"${SYSTEM_REF}\",
    \"filePathInRepository\": \"stacks/apps/docker-compose.yml\",
    \"repositoryAuthentication\": true,
    \"repositoryUsername\": \"ci-bot\",
    \"repositoryPassword\": \"${GITHUB_TOKEN}\",
    \"autoUpdate\": {
      \"interval\": \"1m\",
      \"webhook\": \"\"
    },
    \"endpointId\": ${ENV_ID}
  }")

echo "${APPS_RESPONSE}" | python3 -m json.tool

WEBHOOK_ID=$(echo "${APPS_RESPONSE}" | \
  python3 -c "import sys,json; print(json.load(sys.stdin).get('AutoUpdate',{}).get('Webhook',''))")

echo "Apps stack webhook: ${PORTAINER_URL}/api/webhooks/${WEBHOOK_ID}"
echo "Save this URL as PORTAINER_WEBHOOK_URL in stable-backend-, UI-Terminal-, terminal-dashboard repo secrets"
