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

clone poky "git://git.yoctoproject.org/poky"
clone meta-openembedded "https://github.com/openembedded/meta-openembedded"
clone meta-freescale "https://github.com/Freescale/meta-freescale"
clone meta-freescale-3rdparty "https://github.com/Freescale/meta-freescale-3rdparty"
clone meta-rust "https://github.com/meta-rust/meta-rust"
clone meta-clang "https://github.com/kraj/meta-clang"
clone meta-rauc "https://github.com/rauc/meta-rauc"

cat <<EOF

Required open-source layers cloned.

Still required (NXP account):
  meta-imx — download the Scarthgap i.MX BSP bundle from NXP and extract to:
    ${YOCTO_BASE}/meta-imx

Then initialize the build environment:
  cd ${CO_PILOT_ROOT}
  source setup-environment.sh co-pilot-imx8mp

EOF

if [[ ! -d "${YOCTO_BASE}/meta-imx/meta-bsp" ]]; then
    echo "note: meta-imx not present yet — needed before bitbake co-pilot-image" >&2
fi
