SUMMARY = "Sigma instrument cluster UI (instrumentation / sigma-dash)"
HOMEPAGE = "https://github.com/sigma/embedded"
LICENSE = "CLOSED"

inherit cargo systemd

# Sole UI application — sources from co-pilot/instrumentation (symlink to embedded/instrumentation)
SRC_URI = " \
    git://${SIGMA_INSTRUMENTATION_SRC};protocol=file;branch=main;name=instrumentation;nobranch=1 \
    file://cluster-ui.service \
    file://co-pilot-ui.env \
"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

DEPENDS += " \
    libgbm \
    libdrm \
    virtual/libgl \
    virtual/libgles2 \
    virtual/libegl \
    fontconfig \
    freetype \
    libxkbcommon \
    wayland-native \
"

# Slint FemtoVG + Wayland (via winit) on i.MX Vivante
export SLINT_BACKEND = "femtovg"
export RUSTFLAGS:append = " --cfg co_pilot_embedded"

CARGO_BUILD_FLAGS = "--release --bin sigma-dash"

SYSTEMD_SERVICE:${PN} = "cluster-ui.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${CARGO_TARGET_SUBDIR}/release/sigma-dash ${D}${bindir}/sigma-dash

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${UNPACKDIR}/cluster-ui.service ${D}${systemd_system_unitdir}/cluster-ui.service
    install -m 0644 ${UNPACKDIR}/co-pilot-ui.env ${D}${sysconfdir}/co-pilot/ui.env
}

FILES:${PN} += " \
    ${bindir}/sigma-dash \
    ${systemd_system_unitdir}/cluster-ui.service \
    ${sysconfdir}/co-pilot/ui.env \
"

RDEPENDS:${PN} += " \
    weston \
    liberation-fonts \
    fontconfig \
"

RPROVIDES:${PN} += "sigma-dash"

# Requires meta-rust in bblayers.conf
