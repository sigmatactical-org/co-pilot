SUMMARY = "Co-Pilot virtual test image (800×480 QEMU UI stack)"
DESCRIPTION = "Minimal Co-Pilot image for local QEMU testing — Weston kiosk and \
instrumentation only, without vehicle/CAN/OTA hardware dependencies."

LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += " \
    ssh-server-openssh \
    tools-debug \
"

IMAGE_FEATURES:remove = "splash hwcodec"

IMAGE_INSTALL = " \
    packagegroup-co-pilot-core \
    packagegroup-co-pilot-graphics \
    co-pilot-services \
    instrumentation \
    ${CORE_IMAGE_EXTRA_INSTALL} \
"

SYSTEMD_DEFAULT_TARGET = "graphical.target"

IMAGE_ROOTFS_EXTRA_SPACE = "262144"

export IMAGE_BASENAME = "co-pilot-image-virt"
