#!/bin/bash
# haiku-digest.sh — Digest recent jsonl files into insights using Haiku
# Usage: Run manually or via cron (midnight auto-run)
# Requires: ANTHROPIC_API_KEY set, jq, curl

set -e

TEAM_DIR="${HOME}/.claude-team"
PROJECTS_DIR="${HOME}/.claude/projects"
RAW_DIR="${TEAM_DIR}/insights/raw"
INDEX="${TEAM_DIR}/insights/index.json"
CACHE_HOURLY="${TEAM_DIR}/insights/index-hourly"

mkdir -p "${RAW_DIR}" "${CACHE_HOURLY}"

LAST_RUN="${TEAM_DIR}/.last_digest_run"
NOW=$(date +%s)
RUN_INTERVAL=86400

if [[ -f "${LAST_RUN}" ]]; then
  LAST=$(cat "${LAST_RUN}")
  ELAPSED=$((NOW - LAST))
  if [[ ${ELAPSED} -lt ${RUN_INTERVAL} ]]; then
    exit 0
  fi
fi

echo "${NOW}" > "${LAST_RUN}"

find "${PROJECTS_DIR}" -name "*.jsonl" -type f -mtime -1 2>/dev/null | while read -r jsonl; do
  CONTENT=$(cat "${jsonl}" | head -100)

  SUMMARY=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
    -H "x-api-key: ${ANTHROPIC_API_KEY}" \
    -H "anthropic-version: 2023-06-01" \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"claude-haiku-4-20250514\",
      \"max_tokens\": 300,
      \"messages\": [{
        \"role\": \"user\",
        \"content\": \"You are a team knowledge extractor. From this Claude Code session log, extract 1-3 actionable insights or traps. Format: JSON array of {name, when_to_use, description}. Be concise. Session log:\n${CONTENT}\"
      }]
    }" 2>/dev/null | jq -r '.content[0].text' || echo "[]")

  if [[ "${SUMMARY}" != "[]" && -n "${SUMMARY}" ]]; then
    UPLOADER=$(whoami)
    UPLOADER_IP=$(hostname -I | awk '{print $1}')
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    for insight in $(echo "${SUMMARY}" | jq -r '.[] | @base64' 2>/dev/null); do
      NAME=$(echo "${insight}" | base64 -d | jq -r '.name')
      WHEN=$(echo "${insight}" | base64 -d | jq -r '.when_to_use')
      DESC=$(echo "${insight}" | base64 -d | jq -r '.description')
      CONTENT_HASH=$(echo "${NAME}${WHEN}${DESC}" | sha256sum | awk '{print $1}')
      RAW_HASH=$(echo "${CONTENT}" | sha256sum | awk '{print $1}')

      echo "{\"name\":\"${NAME}\",\"uploader\":\"${UPLOADER}\",\"uploader_ip\":\"${UPLOADER_IP}\",\"when_to_use\":\"${WHEN}\",\"description\":\"${DESC}\",\"content_hash\":\"${CONTENT_HASH}\",\"raw_hashes\":[\"${RAW_HASH}\"],\"created_at\":\"${TIMESTAMP}\"}" | jq '.' >> "${INDEX}" 2>/dev/null || true
    done
  fi
done

cp "${INDEX}" "${CACHE_HOURLY}/index-$(date +%Y%m%d%H).json"

echo "[insights-share] Haiku digest complete"
