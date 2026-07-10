#!/usr/bin/env bash
# Write an OTA catalog entry matching sigma-instrumentation updates.rs.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <artifact-dir>" >&2
  exit 1
fi

ARTIFACT_DIR="$(cd "$1" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINGMAN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MANIFEST="${MANIFEST:-${WINGMAN_ROOT}/release-manifest.json}"

CHANNEL="${SIGMA_UPDATES_CHANNEL:-dev}"
VERSION="$(python3 - <<'PY' "${MANIFEST}"
import json, sys
print(json.load(open(sys.argv[1])).get("image_version", "0.0.0"))
PY
)"
NOTES="${SIGMA_RELEASE_NOTES:-Sigma Racer Wingman ${VERSION}}"
BASE_URL="${SIGMA_UPDATES_BASE_URL:-https://updates.example.invalid}"

bundle="$(find "${ARTIFACT_DIR}" -maxdepth 1 -name '*.raucb' -print -quit || true)"
if [[ -n "${bundle}" ]]; then
  bundle_name="$(basename "${bundle}")"
  bundle_url="${BASE_URL}/v1/channel/${CHANNEL}/bundle/${bundle_name}"
else
  bundle_url=""
fi

python3 - <<'PY' "${ARTIFACT_DIR}/catalog-latest.json" "${CHANNEL}" "${VERSION}" "${NOTES}" "${bundle_url}"
import json, sys
path, channel, version, notes, bundle_url = sys.argv[1:]
payload = {
    "channel": channel,
    "version": version,
    "notes": notes,
    "install": "rauc install" if bundle_url else "",
    "bundle_url": bundle_url,
}
with open(path, "w", encoding="utf-8") as f:
    json.dump(payload, f, indent=2)
    f.write("\n")
print(f"wrote {path}")
PY

# Channel layout expected by the cluster UI poller.
mkdir -p "${ARTIFACT_DIR}/catalog"
cp "${ARTIFACT_DIR}/catalog-latest.json" \
  "${ARTIFACT_DIR}/catalog/v1-channel-${CHANNEL}-latest.json"
