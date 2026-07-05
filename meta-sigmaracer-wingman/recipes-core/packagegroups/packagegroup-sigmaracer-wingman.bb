SUMMARY = "Sigma Racer Wingman core system packages"
LICENSE = "MIT"

inherit packagegroup

PACKAGES = " \
    packagegroup-sigmaracer-wingman-core \
    packagegroup-sigmaracer-wingman-graphics \
    packagegroup-sigmaracer-wingman-vehicle \
    packagegroup-sigmaracer-wingman-navigation \
    packagegroup-sigmaracer-wingman-connectivity \
    packagegroup-sigmaracer-wingman-diagnostics \
    packagegroup-sigmaracer-wingman-ota \
    packagegroup-sigmaracer-wingman-camera \
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
    sigmaracer-wingman-user \
"

RDEPENDS:${PN}-graphics = " \
    weston \
    weston-init \
    seatd \
    sigmaracer-wingman-services \
    instrumentation \
    liberation-fonts \
"

RDEPENDS:${PN}-vehicle = " \
    can-utils \
    iproute2 \
    vehicle-service \
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
    strace \
    htop \
    logger-service \
    diagnostics-service \
"

RDEPENDS:${PN}-ota = " \
    rauc \
    rauc-conf-sigmaracer-wingman \
    ota-service \
"

RDEPENDS:${PN}-camera = " \
    v4l-utils \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    camera-service \
"
