#!/usr/bin/env bash
# Upload release artifacts to S3-compatible object storage.
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

export AWS_ACCESS_KEY_ID="${SIGMA_ARTIFACT_ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${SIGMA_ARTIFACT_SECRET_KEY}"
export AWS_DEFAULT_REGION="${SIGMA_ARTIFACT_REGION:-us-east-1}"

if ! command -v aws >/dev/null 2>&1; then
  pip install --quiet --user awscli
  export PATH="${HOME}/.local/bin:${PATH}"
fi

PREFIX="${SIGMA_ARTIFACT_PREFIX:-wingman}"
CHANNEL="${SIGMA_UPDATES_CHANNEL:-dev}"

upload() {
  local src="$1"
  local key="$2"
  echo "upload s3://${SIGMA_ARTIFACT_BUCKET}/${key}"
  aws --endpoint-url "${SIGMA_ARTIFACT_ENDPOINT}" s3 cp "${src}" \
    "s3://${SIGMA_ARTIFACT_BUCKET}/${key}"
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
