#!/usr/bin/env bash
# Fetches the official Claude Code changelog and posts newly released
# versions since the last run to Slack via an Incoming Webhook.
#
# Required env var: SLACK_WEBHOOK_URL
set -euo pipefail

: "${SLACK_WEBHOOK_URL:?SLACK_WEBHOOK_URL is not set}"

STATE_DIR=".claude-digest-state"
STATE_FILE="${STATE_DIR}/last_version.txt"
mkdir -p "${STATE_DIR}"

CHANGELOG_URL="https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md"
CHANGELOG_WEB_URL="https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md"
CHANGELOG_LOCAL="/tmp/claude-code-changelog.md"

curl -fsSL "${CHANGELOG_URL}" -o "${CHANGELOG_LOCAL}"

mapfile -t VERSIONS < <(grep -oE '^## [0-9]+\.[0-9]+\.[0-9]+' "${CHANGELOG_LOCAL}" | sed 's/^## //')

if [ "${#VERSIONS[@]}" -eq 0 ]; then
  echo "No version headers found in changelog; aborting." >&2
  exit 1
fi

LATEST_VERSION="${VERSIONS[0]}"
LAST_SEEN=""
if [ -f "${STATE_FILE}" ]; then
  LAST_SEEN="$(cat "${STATE_FILE}")"
fi

NEW_VERSIONS=()
for v in "${VERSIONS[@]}"; do
  if [ "${v}" = "${LAST_SEEN}" ]; then
    break
  fi
  NEW_VERSIONS+=("${v}")
done

if [ -z "${LAST_SEEN}" ]; then
  # First run: only report the latest version, don't dump full history.
  NEW_VERSIONS=("${LATEST_VERSION}")
fi

if [ "${#NEW_VERSIONS[@]}" -eq 0 ]; then
  echo "No new Claude Code releases since ${LAST_SEEN}."
  echo "${LATEST_VERSION}" > "${STATE_FILE}"
  exit 0
fi

extract_section() {
  local version="$1"
  awk -v ver="## ${version}" '
    $0 == ver {found=1; next}
    found && /^## / {exit}
    found {print}
  ' "${CHANGELOG_LOCAL}"
}

MAX_VERSIONS_DETAILED=2
MAX_BULLETS_PER_VERSION=6

LINES=()
LINES+=("📢 *Claude Code 最新情報* ($(date -u +%Y-%m-%d))")
LINES+=("")

i=0
for v in "${NEW_VERSIONS[@]}"; do
  i=$((i + 1))
  if [ "${i}" -gt "${MAX_VERSIONS_DETAILED}" ]; then
    remaining=("${NEW_VERSIONS[@]:$((i - 1))}")
    joined="$(IFS=,; echo "${remaining[*]}")"
    LINES+=("他にも新しいリリースがあります: ${joined}")
    break
  fi

  bullets_all="$(extract_section "${v}" | grep -E '^- ' || true)"
  total=0
  if [ -n "${bullets_all}" ]; then
    total=$(printf '%s\n' "${bullets_all}" | wc -l)
  fi

  LINES+=("*v${v}*")
  if [ -n "${bullets_all}" ]; then
    while IFS= read -r line; do
      LINES+=("${line}")
    done < <(printf '%s\n' "${bullets_all}" | head -n "${MAX_BULLETS_PER_VERSION}")
  fi
  if [ "${total}" -gt "${MAX_BULLETS_PER_VERSION}" ]; then
    LINES+=("  ...他$((total - MAX_BULLETS_PER_VERSION))件")
  fi
  LINES+=("")
done

LINES+=("詳細: ${CHANGELOG_WEB_URL}")

BODY="$(printf '%s\n' "${LINES[@]}")"

PAYLOAD="$(jq -n --arg text "${BODY}" '{text: $text}')"

HTTP_CODE="$(curl -sS -o /tmp/slack_response.txt -w '%{http_code}' \
  -X POST -H 'Content-type: application/json' \
  --data "${PAYLOAD}" "${SLACK_WEBHOOK_URL}")"

if [ "${HTTP_CODE}" -lt 200 ] || [ "${HTTP_CODE}" -ge 300 ]; then
  echo "Slack post failed with HTTP ${HTTP_CODE}: $(cat /tmp/slack_response.txt)" >&2
  exit 1
fi

echo "Posted digest for versions: ${NEW_VERSIONS[*]}"
echo "${LATEST_VERSION}" > "${STATE_FILE}"
