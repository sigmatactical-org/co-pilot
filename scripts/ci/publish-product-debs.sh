#!/usr/bin/env bash
# Collect Wingman product .deb packages from a Yocto deploy tree and publish
# them via sigma-updates-cli (OIDC client-credentials → Identity → updates).
#
# Usage:
#   BUILD_DIR=/path/to/build ./scripts/ci/publish-product-debs.sh
#
# Required env:
#   SIGMA_UPDATES_URL          Identity …/api (OIDC) or updates base (shared token)
# And one of:
#   SIGMA_INTERNAL_TOKEN       Direct updates auth (kind/localdev HTTP)
#   SIGMA_OIDC_CLIENT_ID + SIGMA_OIDC_CLIENT_SECRET + (SIGMA_OIDC_TOKEN_URL|SIGMA_OIDC_ISSUER)
#
# Optional:
#   BUILD_DIR                  Yocto build dir (default: shared host build from resolve-cache-dirs)
#   SIGMA_UPDATES_CLI          Path to sigma-updates-cli binary
#   UPDATES_SRC                Checkout of sigmatactical-org/updates (cargo install fallback)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINGMAN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck source=/dev/null
export SIGMA_BUILD_SUBDIR="${SIGMA_BUILD_SUBDIR:-build}"
source "${SCRIPT_DIR}/resolve-cache-dirs.sh"
BUILD_DIR="${BUILD_DIR:-${SIGMA_BUILD_DIR:-${WINGMAN_ROOT}/build}}"
DEPLOY_DEB="${BUILD_DIR}/tmp/deploy/deb"

if [[ ! -d "${DEPLOY_DEB}" ]]; then
  echo "error: deploy/deb not found at ${DEPLOY_DEB}" >&2
  exit 1
fi

: "${SIGMA_UPDATES_URL:?SIGMA_UPDATES_URL is required (Identity …/api or updates base URL)}"
case "${SIGMA_UPDATES_URL}" in
  http://*|https://*) ;;
  *)
    echo "error: SIGMA_UPDATES_URL must be an absolute http(s) URL, got: ${SIGMA_UPDATES_URL}" >&2
    echo "hint: set SIGMA_UPDATES_PUBLISH_URL or SIGMA_IDENTITY_PUBLIC_URL" >&2
    exit 1
    ;;
esac

has_token=0
has_oidc=0
[[ -n "${SIGMA_INTERNAL_TOKEN:-}" ]] && has_token=1
if [[ -n "${SIGMA_OIDC_CLIENT_ID:-}" && -n "${SIGMA_OIDC_CLIENT_SECRET:-}" ]]; then
  if [[ -n "${SIGMA_OIDC_TOKEN_URL:-}" || -n "${SIGMA_OIDC_ISSUER:-}" ]]; then
    has_oidc=1
  fi
fi
if [[ "${has_token}" -eq 0 && "${has_oidc}" -eq 0 ]]; then
  echo "error: set SIGMA_INTERNAL_TOKEN (direct updates) or OIDC client id/secret + issuer/token URL" >&2
  exit 1
fi

ensure_cli() {
  if [[ -n "${SIGMA_UPDATES_CLI:-}" && -x "${SIGMA_UPDATES_CLI}" ]]; then
    echo "${SIGMA_UPDATES_CLI}"
    return
  fi
  if command -v sigma-updates-cli >/dev/null 2>&1; then
    command -v sigma-updates-cli
    return
  fi
  local src="${UPDATES_SRC:-}"
  if [[ -z "${src}" && -d "${WINGMAN_ROOT}/../../it/updates/cli" ]]; then
    src="$(cd "${WINGMAN_ROOT}/../../it/updates" && pwd)"
  fi
  if [[ -z "${src}" || ! -d "${src}/cli" ]]; then
    echo "error: sigma-updates-cli not on PATH; set SIGMA_UPDATES_CLI or UPDATES_SRC" >&2
    exit 1
  fi
  local prefix="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/sigma-updates-cli-prefix"
  echo "==> cargo install sigma-updates-cli from ${src}" >&2
  cargo install --locked --path "${src}/cli" --root "${prefix}" --force
  echo "${prefix}/bin/sigma-updates-cli"
}

CLI="$(ensure_cli)"

STAGE="$(mktemp -d "${TMPDIR:-/tmp}/wingman-product-debs.XXXXXX")"
cleanup() { rm -rf "${STAGE}"; }
trap cleanup EXIT

# Runtime product packages only (exclude -dev / -dbg).
PATTERNS=(
  'sigma-racer-sidearm-firmware_*.deb'
  'sigma-racer-vehicle_*.deb'
  'sigma-racer-cluster_*.deb'
  'sigma-racer-wingman-services_*.deb'
)

found=0
for pat in "${PATTERNS[@]}"; do
  while IFS= read -r -d '' deb; do
    base="$(basename "${deb}")"
    case "${base}" in
      *-dev_*|*-dbg_*) continue ;;
    esac
    cp -a "${deb}" "${STAGE}/"
    echo "staged ${base}"
    found=$((found + 1))
  done < <(find "${DEPLOY_DEB}" -type f -name "${pat}" -print0)
done

if [[ "${found}" -eq 0 ]]; then
  echo "error: no product .deb packages matched under ${DEPLOY_DEB}" >&2
  exit 1
fi

echo "==> publishing ${found} package(s) to ${SIGMA_UPDATES_URL}"
"${CLI}" push "${STAGE}" --allow-missing-deps --url "${SIGMA_UPDATES_URL}"
