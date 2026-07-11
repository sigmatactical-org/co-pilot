#!/usr/bin/env bash
# CI entry: build the QEMU virt image (no NXP BSP).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI_SCRIPT_DIR="${SCRIPT_DIR}"
WINGMAN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EMBEDDED_ROOT="${EMBEDDED_ROOT:-$(cd "${WINGMAN_ROOT}/.." && pwd)}"

export EMBEDDED_ROOT
export YOCTO_BASE="${YOCTO_BASE:-${EMBEDDED_ROOT}}"

cd "${WINGMAN_ROOT}"

if [[ "${SKIP_SIBLING_CHECKOUT:-0}" != "1" ]]; then
  "${SCRIPT_DIR}/prepare-workspace.sh"
fi

"${WINGMAN_ROOT}/scripts/bootstrap-layers.sh" --virt-only

# shellcheck source=/dev/null
export SIGMA_BUILD_SUBDIR=build-virt
source "${SCRIPT_DIR}/resolve-cache-dirs.sh"
BUILD_DIR="${SIGMA_BUILD_DIR:-build-virt}"

# setup-environment.sh must be sourced so bitbake inherits the environment.
set +u
# shellcheck source=/dev/null
source "${WINGMAN_ROOT}/setup-environment.sh" sigma-racer-wingman-qemu "${BUILD_DIR}"
set -u

"${CI_SCRIPT_DIR}/prepare-bitbake.sh" "${BUILD_DIR}"

bitbake sigma-racer-wingman-image-virt

if [[ "${BUILD_DIR}" = /* ]]; then
  DEPLOY_DIR="${BUILD_DIR}/tmp/deploy/images"
else
  DEPLOY_DIR="${WINGMAN_ROOT}/${BUILD_DIR}/tmp/deploy/images"
fi

echo
echo "virt image:"
find "${DEPLOY_DIR}" -name '*.wic*' -o -name '*.manifest' 2>/dev/null | head -20
