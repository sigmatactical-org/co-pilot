#!/usr/bin/env bash
# Refresh release-manifest.json repo refs from sibling checkouts under embedded/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WINGMAN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EMBEDDED_ROOT="${EMBEDDED_ROOT:-$(cd "${WINGMAN_ROOT}/.." && pwd)}"
MANIFEST="${MANIFEST:-${WINGMAN_ROOT}/release-manifest.json}"

python3 - "${MANIFEST}" "${WINGMAN_ROOT}" "${EMBEDDED_ROOT}" <<'PY'
import json, subprocess, sys
from pathlib import Path

manifest_path, wingman_root, embedded_root = map(Path, sys.argv[1:4])
data = json.loads(manifest_path.read_text())

data["repos"]["sigma-racer-wingman"]["ref"] = subprocess.check_output(
    ["git", "-C", wingman_root, "rev-parse", "HEAD"], text=True
).strip()

for name in list(data["repos"]):
    if name == "sigma-racer-wingman":
        continue
    repo = embedded_root / name
    if not (repo / ".git").exists():
        print(f"skip {name} (not checked out)", file=sys.stderr)
        continue
    data["repos"][name]["ref"] = subprocess.check_output(
        ["git", "-C", repo, "rev-parse", "HEAD"], text=True
    ).strip()

manifest_path.write_text(json.dumps(data, indent=2) + "\n")
print(f"updated {manifest_path}")
PY
