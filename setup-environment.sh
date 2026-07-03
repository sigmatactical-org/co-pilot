#!/usr/bin/env bash
# Initialize Yocto build environment for Sigma Co-Pilot.
#
# Usage (recommended):
#   source setup-environment.sh [MACHINE]
#
# Do not run as ./setup-environment.sh — that works for CI but sourcing is
# required for bitbake to see the environment.

_CO_PILOT_SETUP_SOURCED=0
if [[ "${BASH_SOURCE[0]:-}" != "${0:-}" ]]; then
    _CO_PILOT_SETUP_SOURCED=1
fi

# set -e + source = exiting parent shell on any failure. Only enforce when executed.
if (( !_CO_PILOT_SETUP_SOURCED )); then
    set -euo pipefail
fi

_co_pilot_fail() {
    echo "error: $*" >&2
    if (( _CO_PILOT_SETUP_SOURCED )); then
        return 1
    fi
    exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CO_PILOT_ROOT="${SCRIPT_DIR}"
EMBEDDED_ROOT="$(cd "${CO_PILOT_ROOT}/.." && pwd)"
YOCTO_BASE="${YOCTO_BASE:-${EMBEDDED_ROOT}}"
POKY_DIR="${YOCTO_BASE}/poky"
BUILD_DIR="${CO_PILOT_ROOT}/build"
MACHINE="${1:-co-pilot-imx8mp}"
BUILD_DIR="${2:-${BUILD_DIR}}"

usage() {
    cat <<EOF
Usage: source setup-environment.sh [MACHINE] [build-dir]

  MACHINE     co-pilot-imx8mp (default) | co-pilot-imx95
  build-dir   ${BUILD_DIR} (default)

Environment:
  YOCTO_BASE  Directory containing poky and meta layers (default: ${EMBEDDED_ROOT})

First-time setup — clone Yocto layers:
  ${CO_PILOT_ROOT}/scripts/bootstrap-layers.sh

Then initialize the build directory:
  cd ${CO_PILOT_ROOT}
  source setup-environment.sh ${MACHINE}

EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    if (( _CO_PILOT_SETUP_SOURCED )); then
        return 0
    fi
    exit 0
fi

if [[ ! -d "${POKY_DIR}" ]]; then
    cat >&2 <<EOF
error: poky not found at ${POKY_DIR}

Clone the Yocto layers first:
  ${CO_PILOT_ROOT}/scripts/bootstrap-layers.sh

Or set YOCTO_BASE to the directory that contains poky/, then re-run:
  export YOCTO_BASE=/path/to/yocto-tree
  source setup-environment.sh ${MACHINE}

EOF
    _co_pilot_fail "missing poky checkout"
fi

if [[ ! -f "${POKY_DIR}/oe-init-build-env" ]]; then
    _co_pilot_fail "invalid poky checkout (oe-init-build-env not found in ${POKY_DIR})"
fi

# oe-init-build-env must be sourced; it sets PATH, BBPATH, and cd's into build/
# shellcheck source=/dev/null
source "${POKY_DIR}/oe-init-build-env" "${BUILD_DIR}" || _co_pilot_fail "oe-init-build-env failed"

# Seed configuration on first run
if [[ ! -f conf/local.conf ]]; then
    cp "${CO_PILOT_ROOT}/conf/local.conf.sample" conf/local.conf
fi

if [[ ! -f conf/bblayers.conf ]] || ! grep -q meta-co-pilot conf/bblayers.conf 2>/dev/null; then
    sed "s|\${CO_PILOT_ROOT}|${CO_PILOT_ROOT}|g" \
        "${CO_PILOT_ROOT}/conf/bblayers.conf.sample" > conf/bblayers.conf
fi

# Ensure machine and distro are set
if ! grep -q '^MACHINE' conf/local.conf; then
    echo "MACHINE = \"${MACHINE}\"" >> conf/local.conf
else
    sed -i "s/^MACHINE.*/MACHINE = \"${MACHINE}\"/" conf/local.conf
fi

if ! grep -q '^DISTRO' conf/local.conf; then
    echo "DISTRO = \"co-pilot\"" >> conf/local.conf
fi

# BitBake reads machine layers from BBLAYERS — warn about missing optional layers
_missing_layers=()
for _layer in \
    "${YOCTO_BASE}/meta-openembedded/meta-oe" \
    "${YOCTO_BASE}/meta-freescale" \
    "${YOCTO_BASE}/meta-rust" \
    "${YOCTO_BASE}/meta-rauc" \
    "${YOCTO_BASE}/meta-imx/meta-bsp"
do
    if [[ ! -d "${_layer}" ]]; then
        _missing_layers+=("${_layer}")
    fi
done

cat <<EOF

Co-Pilot environment ready.
  MACHINE=${MACHINE}
  DISTRO=co-pilot
  BUILD=${BUILD_DIR}
  POKY=${POKY_DIR}

Build image:
  bitbake co-pilot-image

EOF

if ((${#_missing_layers[@]} > 0)); then
    echo "warning: missing layer checkouts (bitbake will fail until these exist):" >&2
    for _layer in "${_missing_layers[@]}"; do
        echo "  - ${_layer}" >&2
    done
    echo "Run: ${CO_PILOT_ROOT}/scripts/bootstrap-layers.sh" >&2
    echo >&2
fi

if (( _CO_PILOT_SETUP_SOURCED )); then
    return 0
fi
