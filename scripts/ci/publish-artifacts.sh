#!/usr/bin/env bash
# Upload release artifacts to S3-compatible object storage (MinIO/AWS).
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <artifact-dir>" >&2
  exit 1
fi

ARTIFACT_DIR="$(cd "$1" && pwd)"

: "${SIGMA_ARTIFACT_ENDPOINT:?SIGMA_ARTIFACT_ENDPOINT is required}"
: "${SIGMA_ARTIFACT_ACCESS_KEY:?SIGMA_ARTIFACT_ACCESS_KEY is required}"
: "${SIGMA_ARTIFACT_SECRET_KEY:?SIGMA_ARTIFACT_SECRET_KEY is required}"
: "${SIGMA_ARTIFACT_BUCKET:?SIGMA_ARTIFACT_BUCKET is required}"

PREFIX="${SIGMA_ARTIFACT_PREFIX:-wingman}"
CHANNEL="${SIGMA_UPDATES_CHANNEL:-dev}"
ALIAS="sigma-artifacts"

ensure_mc() {
  if command -v mc >/dev/null 2>&1; then
    command -v mc
    return
  fi
  local bin_dir="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/sigma-mc"
  local mc_bin="${bin_dir}/mc"
  mkdir -p "${bin_dir}"
  if [[ ! -x "${mc_bin}" ]]; then
    echo "==> downloading MinIO client (mc) into ${bin_dir}" >&2
    curl -fsSL "https://dl.min.io/client/mc/release/linux-amd64/mc" -o "${mc_bin}"
    chmod +x "${mc_bin}"
  fi
  echo "${mc_bin}"
}

MC="$(ensure_mc)"

echo "==> configuring mc alias ${ALIAS} → ${SIGMA_ARTIFACT_ENDPOINT}"
"${MC}" alias set "${ALIAS}" "${SIGMA_ARTIFACT_ENDPOINT}" \
  "${SIGMA_ARTIFACT_ACCESS_KEY}" "${SIGMA_ARTIFACT_SECRET_KEY}" >/dev/null

# Ensure bucket exists (idempotent).
"${MC}" mb --ignore-existing "${ALIAS}/${SIGMA_ARTIFACT_BUCKET}" >/dev/null

upload() {
  local src="$1"
  local key="$2"
  echo "upload s3://${SIGMA_ARTIFACT_BUCKET}/${key}"
  "${MC}" cp "${src}" "${ALIAS}/${SIGMA_ARTIFACT_BUCKET}/${key}"
}

for f in "${ARTIFACT_DIR}"/*; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f")"
  case "${base}" in
    *.raucb)
      upload "${f}" "${PREFIX}/v1/channel/${CHANNEL}/bundle/${base}"
      ;;
    catalog-latest.json)
      upload "${f}" "${PREFIX}/v1/channel/${CHANNEL}/latest"
      ;;
    catalog/*) ;;
    *)
      upload "${f}" "${PREFIX}/images/${base}"
      ;;
  esac
done

if [[ -f "${ARTIFACT_DIR}/catalog-latest.json" ]]; then
  upload "${ARTIFACT_DIR}/catalog-latest.json" "${PREFIX}/v1/channel/${CHANNEL}/latest"
fi

echo "publish complete"
