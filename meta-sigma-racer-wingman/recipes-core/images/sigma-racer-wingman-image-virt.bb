SUMMARY = "Sigma Racer Wingman virtual test image (800×480 QEMU UI stack)"
DESCRIPTION = "Minimal Sigma Racer Wingman image for local QEMU testing — Weston kiosk and \
instrumentation only, without vehicle/CAN/OTA hardware dependencies."

LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += " \
    ssh-server-openssh \
    tools-debug \
    debug-tweaks \
"

IMAGE_FEATURES:remove = "splash hwcodec"

IMAGE_INSTALL = " \
    packagegroup-sigma-racer-wingman-core \
    packagegroup-sigma-racer-wingman-graphics \
    sigma-racer-wingman-services \
    vehicle-service \
    instrumentation \
    ${CORE_IMAGE_EXTRA_INSTALL} \
"

SYSTEMD_DEFAULT_TARGET = "graphical.target"

IMAGE_ROOTFS_EXTRA_SPACE = "262144"

export IMAGE_BASENAME = "sigma-racer-wingman-image-virt"
