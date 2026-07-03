#!/usr/bin/env bash
# Clone Yocto Project Scarthgap layers required by Co-Pilot into embedded/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CO_PILOT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
YOCTO_BASE="${YOCTO_BASE:-$(cd "${CO_PILOT_ROOT}/.." && pwd)}"
BRANCH="${YOCTO_BRANCH:-scarthgap}"

clone() {
    local name="$1"
    local url="$2"
    local dest="${YOCTO_BASE}/${name}"

    if [[ -d "${dest}/.git" ]]; then
        echo "ok  ${name} (already cloned)"
        return 0
    fi

    echo "clone ${name} (${BRANCH}) ..."
    git clone -b "${BRANCH}" --depth 1 "${url}" "${dest}"
}

echo "Co-Pilot Yocto bootstrap"
echo "  YOCTO_BASE=${YOCTO_BASE}"
echo "  branch=${BRANCH}"
echo

clone poky "https://git.yoctoproject.org/poky"
clone meta-openembedded "https://github.com/openembedded/meta-openembedded"
clone meta-rust "https://github.com/meta-rust/meta-rust"
clone meta-clang "https://github.com/kraj/meta-clang"
clone meta-rauc "https://github.com/rauc/meta-rauc"

VIRT_ONLY="${1:-}"
if [[ "${VIRT_ONLY}" != "--virt-only" ]]; then
    clone meta-freescale "https://github.com/Freescale/meta-freescale"
    clone meta-freescale-3rdparty "https://github.com/Freescale/meta-freescale-3rdparty"
fi

cat <<EOF

Required open-source layers cloned.

EOF

if [[ "${VIRT_ONLY}" == "--virt-only" ]]; then
    cat <<EOF
Virtual target (co-pilot-qemu) — meta-imx / Freescale BSP not required.

Initialize and build:
  cd ${CO_PILOT_ROOT}
  source setup-environment.sh co-pilot-qemu
  bitbake co-pilot-image-virt
  ./scripts/run-qemu.sh

EOF
else
    cat <<EOF
Still required (NXP account):
  meta-imx — download the Scarthgap i.MX BSP bundle from NXP and extract to:
    ${YOCTO_BASE}/meta-imx

Then initialize the build environment:
  cd ${CO_PILOT_ROOT}
  source setup-environment.sh co-pilot-imx8mp

Virtual testing (no NXP BSP):
  ${CO_PILOT_ROOT}/scripts/bootstrap-layers.sh --virt-only
  source setup-environment.sh co-pilot-qemu

EOF

    if [[ ! -d "${YOCTO_BASE}/meta-imx/meta-bsp" ]]; then
        echo "note: meta-imx not present yet — needed for hardware bitbake, not for co-pilot-qemu" >&2
    fi
fi
