#!/usr/bin/env bash
# Clone or update a sibling repository under embedded/.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: checkout-sibling.sh <name> <url> <ref>

  name  Directory under EMBEDDED_ROOT (e.g. sigma-racer-cluster)
  url   Git remote URL
  ref   Branch, tag, or full SHA
EOF
}

if [[ $# -ne 3 ]]; then
  usage >&2
  exit 1
fi

NAME="$1"
URL="$2"
REF="$3"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EMBEDDED_ROOT="${EMBEDDED_ROOT:-$(cd "${SCRIPT_DIR}/../../.." && pwd)}"
DEST="${EMBEDDED_ROOT}/${NAME}"

if [[ -d "${DEST}/.git" ]]; then
  git -C "${DEST}" fetch --depth 1 origin "${REF}" 2>/dev/null \
    || git -C "${DEST}" fetch --depth 1 origin
  git -C "${DEST}" checkout --detach "${REF}"
else
  mkdir -p "${EMBEDDED_ROOT}"
  if git ls-remote --exit-code "${URL}" "${REF}" >/dev/null 2>&1; then
    git clone --depth 1 --branch "${REF}" "${URL}" "${DEST}"
  else
    git clone "${URL}" "${DEST}"
    git -C "${DEST}" checkout --detach "${REF}"
  fi
fi

echo "ok  ${NAME} @ $(git -C "${DEST}" rev-parse --short HEAD)"
