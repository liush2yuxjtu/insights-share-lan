#!/bin/bash
# generate-index.sh — Add new insight to local index
# Usage: upload-insight skill calls this after capturing raw content

set -e

TEAM_DIR="${HOME}/.claude-team"
INDEX="${TEAM_DIR}/insights/index.json"
RAW_DIR="${TEAM_DIR}/insights/raw"

mkdir -p "${TEAM_DIR}/insights" "${RAW_DIR}"

NEW_ENTRY="$1"

if [[ -z "${NEW_ENTRY}" ]]; then
  echo "Usage: generate-index.sh '<json-entry>'"
  exit 1
fi

if [[ ! -f "${INDEX}" ]]; then
  echo "[]" > "${INDEX}"
fi

TEMP=$(mktemp)
jq --argjson entry "${NEW_ENTRY}" '. += [$entry]' "${INDEX}" > "${TEMP}" && mv "${TEMP}" "${INDEX}"

echo "[insights-share] Index updated"
