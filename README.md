# Sigma Co-Pilot — Motorcycle Instrument Cluster Yocto Distribution

Custom Yocto Project distribution for an offline-first motorcycle instrument cluster on NXP i.MX 8M Plus / i.MX 95 class hardware.

## Overview

| Item | Value |
|------|-------|
| Distro | `co-pilot` |
| Yocto LTS | Scarthgap (5.0) |
| Init | systemd |
| Display | Wayland + Weston (kiosk) |
| UI | Rust + Slint (`sigma-dash`) |
| BSP | NXP meta-imx (i.MX 8M Plus / i.MX 95) |
| OTA | RAUC A/B (optional, production) |

## Repository layout

```
co-pilot/
├── instrumentation/       → symlink to ../instrumentation (sole UI)
├── conf/                  Sample bblayers.conf and local.conf
├── docs/                  Architecture and requirements
├── meta-co-pilot/         Custom Yocto layer
│   ├── recipes-co-pilot/instrumentation/   sigma-dash binary + cluster-ui.service
│   └── ...
├── setup-environment.sh
└── build/
```

## UI

**instrumentation** (`sigma-dash`) is the only UI on the device. Weston runs as a headless Wayland compositor; the cluster app fills the screen via `cluster-ui.service`.

Boot chain: `graphical.target` → `co-pilot-ui.target` → `weston.service` + `cluster-ui.service` → `/usr/bin/sigma-dash`

## Quick start

### 1. Clone dependent layers (sibling to `co-pilot/` under `embedded/`)

```bash
cd ~/Source/sigma/embedded

git clone -b scarthgap git://git.yoctoproject.org/poky
git clone -b scarthgap https://github.com/openembedded/meta-openembedded
git clone -b scarthgap https://github.com/Freescale/meta-freescale
git clone -b scarthgap https://github.com/Freescale/meta-freescale-3rdparty
git clone -b scarthgap https://github.com/meta-rust/meta-rust
git clone -b scarthgap https://github.com/kraj/meta-clang
git clone -b scarthgap https://github.com/rauc/meta-rauc

# NXP i.MX BSP — download from NXP matching Scarthgap release
# Extract meta-imx into embedded/meta-imx
```

### 2. Initialize build environment

```bash
cd ~/Source/sigma/embedded/co-pilot
chmod +x setup-environment.sh
source setup-environment.sh co-pilot-imx8mp
```

### 3. Build

```bash
# Accept NXP EULA in conf/local.conf if required:
# ACCEPT_FSL_EULA = "1"

bitbake co-pilot-image
```

Output: `build/tmp/deploy/images/co-pilot-imx8mp/co-pilot-image-co-pilot-imx8mp.wic.gz`

### 4. Flash

```bash
zcat tmp/deploy/images/co-pilot-imx8mp/co-pilot-image-co-pilot-imx8mp.wic.gz | sudo dd of=/dev/sdX bs=4M status=progress
```

## System services

| Service | Purpose |
|---------|---------|
| `weston.service` | Wayland compositor (no UI of its own) |
| `cluster-ui.service` | **instrumentation** — sole UI (`/usr/bin/sigma-dash`) |
| `vehicle.service` | CAN / vehicle signal abstraction |
| `navigation.service` | Turn-by-turn / map window |
| `gps.service` | GNSS input |
| `bluetooth.service` | BlueZ companion phone interface |
| `camera.service` | V4L2 camera / PiP |
| `logger.service` | Ride logs, CAN capture |
| `ota.service` | RAUC update orchestration |
| `diagnostics.service` | DTC / health monitoring |

Stub services (`vehicle`, `navigation`, etc.) install placeholder daemons until real implementations land. Replace recipes under `recipes-co-pilot/` as subsystems mature.

## Production options

Enable in `conf/local.conf`:

```bitbake
DISTRO_FEATURES:append = " rauc read-only-rootfs tpm2"
EXTRA_IMAGE_FEATURES += " read-only-rootfs"
```

Configure RAUC signing keys (never commit production keys):

```bitbake
RAUC_KEY_FILE = "${TOPDIR}/../keys/rauc/development-key.pem"
RAUC_CERT_FILE = "${TOPDIR}/../keys/rauc/development-ca.cert.pem"
```

## Instrumentation UI integration

The **instrumentation** project is linked at `co-pilot/instrumentation` (symlink to `../instrumentation`) and built as the `instrumentation` Yocto package. It is the only UI on the image.

Override source path in `local.conf`:

```bitbake
SIGMA_INSTRUMENTATION_SRC = "/path/to/instrumentation"
```

Desktop dev (windowed):

```bash
cd ../instrumentation && cargo run --bin sigma-dash
```

Target kiosk (fullscreen, set automatically when built with `--cfg co_pilot_embedded` or `SLINT_FULLSCREEN=1`):

```bash
SLINT_FULLSCREEN=1 cargo run --bin sigma-dash
```

## UI window model

The cluster application implements:

- **Persistent layer** — speed, RPM, warnings (always visible)
- **Windowed content** — Navigation, Connectivity, Diagnostics, Camera, Systems, Fuel, Maintenance, Security, GPS/Compass

See `docs/ARCHITECTURE.md` for service boundaries and data flow.

## Requirements traceability

Full specification: `docs/REQUIREMENTS.md`

## License

Layer metadata: MIT. Image contents inherit respective upstream licenses. NXP BSP components require EULA acceptance.
