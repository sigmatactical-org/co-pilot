# CI/CD — Sigma Racer Wingman

GitHub-hosted runners are used for **fast Rust gates** only. Yocto image builds run on a **self-hosted** runner with persistent `downloads/` and `sstate-cache/`. Large binaries live in **S3-compatible object storage**, not GitHub artifact storage.

## Layout

```
embedded/
├── sigma-racer-wingman/      # Yocto distro + CI orchestration
├── sigma-instrumentation/    # Slint UI library
├── sigma-racer-cluster/      # Production cluster binary
├── sigma-racer-telemetry/    # VSS / IPC
├── sigma-racer-sidearm/      # M7 firmware
└── sigma-racer-vehicle/      # Vehicle daemon
```

Rust CI checks out siblings into `embedded/` to match local `.cargo/config.toml` path patches.

## Rust CI (GitHub-hosted)

| Repo | Workflow | Runner |
|------|----------|--------|
| `sigma-instrumentation` | `.github/workflows/ci.yml` | `ubuntu-latest` |
| `sigma-racer-cluster` | `.github/workflows/ci.yml` | `ubuntu-latest` |
| `sigma-racer-sidearm` | `.github/workflows/ci.yml` | `ubuntu-latest` |
| `sigma-racer-telemetry` | `.github/workflows/ci.yml` | `ubuntu-latest` |

Typical runtime: 2–5 minutes. Uses `Swatinem/rust-cache@v2`.

## Yocto CI (self-hosted)

### Register a runner

On your build machine (the box that already runs `bitbake`):

```bash
# In GitHub: Settings → Actions → Runners → New self-hosted runner
./config.sh --labels yocto
./run.sh
```

Recommended persistent paths (already in `conf/local.conf.sample`):

```
embedded/sigma-racer-wingman/downloads/
embedded/sigma-racer-wingman/sstate-cache/
```

CI bitbake scripts call `scripts/ci/resolve-cache-dirs.sh` before `setup-environment.sh`. When the host dev tree exists at `$HOME/Source/sigma/embedded/sigma-racer-wingman/`, CI reuses those `downloads/`, `sstate-cache/`, and `build-virt/` dirs instead of warming a separate copy under the Actions workspace (the deep `_work/...` path can make `apt-get` fail during `do_rootfs` with `File name too long`). Override explicitly:

```bash
export SIGMA_DL_DIR=/path/to/downloads
export SIGMA_SSTATE_DIR=/path/to/sstate-cache
export SIGMA_BUILD_DIR=/path/to/build-virt
```

### Virt integration build

Workflow: `.github/workflows/yocto-virt.yml`

- **Triggers:** `main` pushes (layer paths), PRs, weekly schedule, manual dispatch
- **Target:** `sigma-racer-wingman-image-virt` (QEMU, no NXP BSP)
- **Runner:** `[self-hosted, yocto]`
- **No artifacts uploaded** — pass/fail only

Local equivalent:

```bash
./scripts/ci/bitbake-virt.sh
```

CI bitbake scripts call `prepare-bitbake.sh` after `setup-environment.sh` to kill any stale cooker/hashserv left by a cancelled prior run on the same workspace.

### Production release build

Workflow: `.github/workflows/yocto-release.yml`

- **Triggers:** tag `wingman-*`, manual dispatch
- **Target:** `sigma-racer-wingman-image` (imx8mp)
- **Requires:** `meta-imx` (auto-linked from `$HOME/Source/sigma/embedded/meta-imx` on the self-hosted runner, or cloned by `scripts/ci/bootstrap-meta-imx.sh`), host `rustup` with `thumbv7em-none-eabihf` for M7 firmware, `ACCEPT_FSL_EULA = "1"`

Local equivalent:

```bash
./scripts/ci/bitbake-release.sh
```

## Release manifest

`release-manifest.json` pins sibling repo SHAs for reproducible release builds. Bump refs when cutting a release:

```bash
# Example: refresh all refs to current main
python3 - <<'PY'
import json, subprocess, pathlib
manifest = pathlib.Path("release-manifest.json")
data = json.loads(manifest.read_text())
for name in data["repos"]:
    if name == "sigma-racer-wingman":
        data["repos"][name]["ref"] = subprocess.check_output(
            ["git", "rev-parse", "HEAD"], text=True
        ).strip()
    else:
        # update manually or from sibling checkout
        pass
manifest.write_text(json.dumps(data, indent=2) + "\n")
PY
```

Also bump `image_version` / `distro_version` and Yocto recipe `SRCREV` values where used.

## Tagging

| Component | Tag format | Publishes |
|-----------|------------|-----------|
| M7 firmware | `v0.2.0` | `.deb` (GitHub Release + optional object store) |
| Wingman image | `wingman-1.0.0` | Product `.deb`s via updates CLI + optional RAUC/image object-store |

### Sidearm deb release

```bash
git tag v0.2.0
git push origin v0.2.0
```

Workflow: `sigma-racer-sidearm/.github/workflows/release.yml` runs `scripts/package-deb.sh`.

### Wingman image release

```bash
# 1. Update release-manifest.json (SHAs + image_version)
# 2. Commit and tag
git tag wingman-1.0.0
git push origin wingman-1.0.0
```

After bitbake, the release workflow:

1. **Publishes product `.deb`s** via `scripts/ci/publish-product-debs.sh` → `sigma-updates-cli` (OIDC client-credentials → Identity `/api/v1/packages`). Packages: `sigma-racer-sidearm-firmware`, `sigma-racer-vehicle`, `sigma-racer-cluster`, `sigma-racer-wingman-services` (runtime only; no `-dev`/`-dbg`).
2. Optionally **uploads image blobs** (`.wic` / `.raucb` / catalog) to object storage when `SIGMA_PUBLISH_ARTIFACTS=true`.

## Product package publish (Identity + CLI)

Configure on `sigma-racer-wingman`:

| Name | Type | Purpose |
|------|------|---------|
| `SIGMA_OIDC_CLIENT_ID` | secret | Keycloak client `sigma-updates-ci` (service account) |
| `SIGMA_OIDC_CLIENT_SECRET` | secret | Client secret |
| `SIGMA_OIDC_TOKEN_URL` | variable | Token endpoint (preferred) |
| `SIGMA_OIDC_ISSUER` | variable | Issuer URL if token URL unset (`…/realms/multcorp`) |
| `SIGMA_IDENTITY_PUBLIC_URL` | variable | Identity public base (CLI uses `{url}/api`). When unset, the release workflow skips product `.deb` publish. |

Dev Keycloak ships client `sigma-updates-ci` with realm role `sigma-admin` on its service account (`identity/dev_realm.json`; also ensured by `platform/scripts/seed-keycloak-dev-users.sh`).

Local smoke:

```bash
export SIGMA_UPDATES_URL=https://identity.sigma.localtest.me:30443/api
export SIGMA_OIDC_CLIENT_ID=sigma-updates-ci
export SIGMA_OIDC_CLIENT_SECRET=dev-sigma-updates-ci-secret-change-me
export SIGMA_OIDC_ISSUER=https://keycloak.sigma.localtest.me:30443/realms/multcorp
./scripts/ci/publish-product-debs.sh
```

## Object storage & OTA catalog

Optional image-blob publish (gated by **`SIGMA_PUBLISH_ARTIFACTS=true`**):

| Name | Type | Purpose |
|------|------|---------|
| `SIGMA_PUBLISH_ARTIFACTS` | variable | Set to `true` to enable S3 upload step |
| `SIGMA_ARTIFACT_ENDPOINT` | secret | S3/MinIO endpoint URL |
| `SIGMA_ARTIFACT_ACCESS_KEY` | secret | Access key |
| `SIGMA_ARTIFACT_SECRET_KEY` | secret | Secret key |
| `SIGMA_ARTIFACT_BUCKET` | variable | Bucket name |
| `SIGMA_ARTIFACT_REGION` | variable | Region (default `us-east-1`) |
| `SIGMA_UPDATES_BASE_URL` | variable | Public catalog base URL |
| `RAUC_KEY_FILE` | secret | Path on runner to signing key |
| `RAUC_CERT_FILE` | secret | Path on runner to cert |

Published layout (matches `sigma-instrumentation` `updates.rs`):

```
s3://{bucket}/wingman/v1/channel/{channel}/latest          # JSON
s3://{bucket}/wingman/v1/channel/{channel}/bundle/*.raucb
s3://{bucket}/wingman/images/*.wic.gz
```

Set on device:

```bash
SIGMA_UPDATES_URL=https://your-cdn.example/wingman
SIGMA_UPDATES_CHANNEL=dev
SIGMA_IMAGE_VERSION=1.0.0
```

## kas (optional local/CI bootstrap)

```bash
pip install kas
cd embedded/sigma-racer-wingman
kas build kas.yml
```

Sibling repos must still exist under `embedded/` before building.

## What stays off GitHub

- Multi-GB `.wic.gz` / `.raucb` blobs (object store only)
- Yocto `sstate-cache/` tarballs via `actions/cache`
- Full imx8mp builds on every PR

## Troubleshooting

**Virt workflow queued forever** — no self-hosted runner with label `yocto`. Register one or run `./scripts/ci/bitbake-virt.sh` locally.

**Release fails on meta-imx** — install NXP BSP per `README.md`; virt builds do not need it.

**Sibling crate patch errors in Rust CI** — verify checkouts land in `embedded/{repo}` and `working-directory` matches the crate being built.
