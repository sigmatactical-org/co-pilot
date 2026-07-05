SUMMARY = "Sigma Sigma Racer Wingman instrument cluster image"
DESCRIPTION = "Offline-first motorcycle instrument cluster with Wayland kiosk UI, \
vehicle CAN interface, navigation, connectivity, and OTA support."

LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += " \
    ssh-server-openssh \
    tools-debug \
    hwcodec \
"

# No splash — instrumentation is the only UI from first frame
IMAGE_FEATURES:remove = "splash"

# Core platform — instrumentation is the sole UI application
IMAGE_INSTALL = " \
    packagegroup-sigma-racer-wingman-core \
    packagegroup-sigma-racer-wingman-graphics \
    packagegroup-sigma-racer-wingman-vehicle \
    packagegroup-sigma-racer-wingman-navigation \
    packagegroup-sigma-racer-wingman-connectivity \
    packagegroup-sigma-racer-wingman-diagnostics \
    packagegroup-sigma-racer-wingman-ota \
    sigma-racer-wingman-services \
    instrumentation \
    ${CORE_IMAGE_EXTRA_INSTALL} \
"

# Boot directly into instrumentation UI (Weston + cluster-ui.service)
SYSTEMD_DEFAULT_TARGET = "graphical.target"

IMAGE_ROOTFS_EXTRA_SPACE = "524288"

WIC_CREATE_EXTRA_ARGS = "--no-fstab-update"

export IMAGE_BASENAME = "sigma-racer-wingman-image"
