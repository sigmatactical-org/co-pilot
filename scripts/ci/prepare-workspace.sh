#!/usr/bin/env bash
# Materialize the embedded/ sibling layout for bitbake EXTERNALSRC.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINGMAN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EMBEDDED_ROOT="${EMBEDDED_ROOT:-$(cd "${WINGMAN_ROOT}/.." && pwd)}"
MANIFEST="${MANIFEST:-${WINGMAN_ROOT}/release-manifest.json}"
ORG="${SIGMA_GITHUB_ORG:-sigmatactical-org}"

if [[ "${SKIP_SIBLING_CHECKOUT:-0}" == "1" ]]; then
  echo "prepare-workspace: SKIP_SIBLING_CHECKOUT=1 — using pre-checked-out siblings"
  exit 0
fi

if [[ ! -f "${MANIFEST}" ]]; then
  echo "error: release manifest not found: ${MANIFEST}" >&2
  exit 1
fi

checkout() {
  local name="$1"
  local ref="$2"
  local url="https://github.com/${ORG}/${name}.git"
  "${SCRIPT_DIR}/checkout-sibling.sh" "${name}" "${url}" "${ref}"
}

echo "prepare-workspace"
echo "  EMBEDDED_ROOT=${EMBEDDED_ROOT}"
echo "  MANIFEST=${MANIFEST}"
echo

while IFS=$'\t' read -r name ref; do
  checkout "${name}" "${ref}"
done < <(python3 - "${MANIFEST}" <<'PY'
import json, sys
data = json.load(open(sys.argv[1]))
for name, spec in data["repos"].items():
    if name == "sigma-racer-wingman":
        continue
    print(f"{name}\t{spec['ref']}")
PY
)

echo
echo "Sibling layout ready under ${EMBEDDED_ROOT}"
