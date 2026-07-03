#!/usr/bin/env bash
# Boot a co-pilot-qemu image in a fixed 800×480 GTK window.
#
# Prerequisites:
#   source setup-environment.sh co-pilot-qemu build-virt
#   bitbake co-pilot-image
#
# Usage:
#   ./scripts/run-qemu.sh [runqemu extra args...]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CO_PILOT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${CO_PILOT_ROOT}/build-virt"

if [[ ! -d "${BUILD_DIR}" ]]; then
    echo "error: ${BUILD_DIR} not found — initialize with:" >&2
    echo "  source setup-environment.sh co-pilot-qemu build-virt" >&2
    exit 1
fi

# shellcheck source=/dev/null
source "${BUILD_DIR}/conf/set-image-info" 2>/dev/null || true

cd "${BUILD_DIR}"

if ! command -v runqemu >/dev/null 2>&1; then
    echo "error: runqemu not in PATH — source setup-environment.sh first" >&2
    exit 1
fi

exec runqemu co-pilot-qemu co-pilot-image-virt slirp "$@"
