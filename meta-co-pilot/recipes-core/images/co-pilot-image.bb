SUMMARY = "Sigma Co-Pilot instrument cluster image"
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
    packagegroup-co-pilot-core \
    packagegroup-co-pilot-graphics \
    packagegroup-co-pilot-vehicle \
    packagegroup-co-pilot-navigation \
    packagegroup-co-pilot-connectivity \
    packagegroup-co-pilot-diagnostics \
    packagegroup-co-pilot-ota \
    co-pilot-services \
    instrumentation \
    ${CORE_IMAGE_EXTRA_INSTALL} \
"

# Boot directly into instrumentation UI (Weston + cluster-ui.service)
SYSTEMD_DEFAULT_TARGET = "graphical.target"

IMAGE_ROOTFS_EXTRA_SPACE = "524288"

WIC_CREATE_EXTRA_ARGS = "--no-fstab-update"

export IMAGE_BASENAME = "co-pilot-image"
