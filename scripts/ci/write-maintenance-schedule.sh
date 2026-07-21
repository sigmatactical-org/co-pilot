#!/usr/bin/env bash
# Emit the maintenance schedule the updates service distributes to shop tools.
#
# The updates service owns and distributes the prescribed schedule the same way
# it owns the OTA catalog (see write-catalog.sh). The source of truth is
# schemas/maintenance/<model>.json; this stamps `published` and drops
# maintenance-schedule.json into the artifact dir for publish-artifacts.sh.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <artifact-dir>" >&2
  exit 1
fi

ARTIFACT_DIR="$(cd "$1" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINGMAN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

MODEL="${SIGMA_VEHICLE_MODEL:-sigma-racer}"
SOURCE="${SIGMA_MAINTENANCE_SCHEDULE:-${WINGMAN_ROOT}/schemas/maintenance/${MODEL}.json}"

if [[ ! -f "${SOURCE}" ]]; then
  echo "no maintenance schedule at ${SOURCE}" >&2
  exit 1
fi

python3 - <<'PY' "${SOURCE}" "${ARTIFACT_DIR}/maintenance-schedule.json" "${MODEL}"
import datetime, json, sys
source, dest, model = sys.argv[1:]
schedule = json.load(open(source))
schedule["model"] = model
# Stamp publish time (UTC, RFC 3339, millis) so clients can show freshness.
schedule["published"] = (
    datetime.datetime.now(datetime.timezone.utc)
    .strftime("%Y-%m-%dT%H:%M:%S.") + f"{0:03d}Z"
)
if "version" not in schedule or not schedule["version"]:
    raise SystemExit("maintenance schedule is missing a version")
with open(dest, "w", encoding="utf-8") as f:
    json.dump(schedule, f, indent=2)
    f.write("\n")
print(f"wrote {dest} (version {schedule['version']}, {len(schedule.get('items', []))} items)")
PY
