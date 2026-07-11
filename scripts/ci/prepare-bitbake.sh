#!/usr/bin/env bash
# Reset stale bitbake cooker/hashserv state before CI builds.
#
# Cancelled or timed-out workflows can leave a cooker daemon alive (or half-dead)
# with BB_HASHSERVE pointing at a unix socket that no longer exists. The next run
# then fails in runqueue with FileNotFoundError on hashserve.sock.
set -euo pipefail

BUILD_DIR="${1:-build-virt}"

if command -v bitbake >/dev/null 2>&1; then
  bitbake -m 2>/dev/null || true
fi

rm -f "${PWD}/hashserve.sock" \
      "${PWD}/cache/hashserv.db" \
      "${PWD}/cache/hashserv.db-shm" \
      "${PWD}/cache/hashserv.db-wal" 2>/dev/null || true

echo "prepare-bitbake: reset cooker/hashserv for ${BUILD_DIR}"
