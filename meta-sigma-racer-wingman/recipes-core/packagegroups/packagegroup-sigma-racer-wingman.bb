SUMMARY = "Sigma Racer Wingman core system packages"
LICENSE = "MIT"

inherit packagegroup

PACKAGES = " \
    packagegroup-sigma-racer-wingman-core \
    packagegroup-sigma-racer-wingman-graphics \
    packagegroup-sigma-racer-wingman-vehicle \
    packagegroup-sigma-racer-wingman-navigation \
    packagegroup-sigma-racer-wingman-connectivity \
    packagegroup-sigma-racer-wingman-diagnostics \
    packagegroup-sigma-racer-wingman-ota \
    packagegroup-sigma-racer-wingman-camera \
"

RDEPENDS:${PN}-core = " \
    systemd \
    systemd-analyze \
    udev \
    bash \
    coreutils \
    iproute2 \
    connman \
    connman-client \
    sqlite3 \
    tzdata \
    sigma-racer-wingman-user \
"

RDEPENDS:${PN}-graphics = " \
    weston \
    weston-init \
    seatd \
    sigma-racer-wingman-services \
    sigma-racer-cluster \
    liberation-fonts \
"

# The M7 (Cortex-M7) firmware is a bare-metal thumbv7em-none-eabihf build.
# QEMU has no M7 — leave off there. i.MX 8M Plus sets INCLUDE_SIDEARM_FIRMWARE=1
# in its machine conf; the recipe builds via host rustup cargo until Yocto
# rust-cross ships that target.
INCLUDE_SIDEARM_FIRMWARE ??= "0"

RDEPENDS:${PN}-vehicle = " \
    can-utils \
    can-network \
    iproute2 \
    sigma-racer-vehicle \
    ${@bb.utils.contains('INCLUDE_SIDEARM_FIRMWARE', '1', 'sigma-racer-sidearm-firmware', '', d)} \
"

RDEPENDS:${PN}-navigation = " \
    gpsd \
    gps-utils \
    navigation-service \
    gps-service \
"

RDEPENDS:${PN}-connectivity = " \
    bluez5 \
    bluez5-obex \
    wpa-supplicant \
    iw \
    bluetooth-service \
"

RDEPENDS:${PN}-diagnostics = " \
    logger-service \
    diagnostics-service \
    ${@bb.utils.contains('SIGMA_RACER_WINGMAN_DEBUG', '1', 'strace htop', '', d)} \
"

RDEPENDS:${PN}-ota = " \
    rauc \
    rauc-conf-sigma-racer-wingman \
    ota-service \
"

RDEPENDS:${PN}-camera = " \
    v4l-utils \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    camera-service \
"
