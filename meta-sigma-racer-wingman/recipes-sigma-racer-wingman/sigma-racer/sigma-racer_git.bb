SUMMARY = "Sigma Racer instrument cluster UI (sigma-racer / sigma-dash)"
HOMEPAGE = "https://github.com/sigmatactical-org/sigma-racer"
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-MIT;md5=a082e45a87ea9bc152345be779914257 \
    file://LICENSE-APACHE;md5=d8b08026ec729e41461816aba7fc28c4 \
"

inherit cargo cargo-update-recipe-crates systemd externalsrc

EXTERNALSRC = "${SIGMA_RACER_SRC}"

SRC_URI = " \
    git://github.com/sigmatactical-org/sigma-racer.git;protocol=https;branch=main;name=racer;nobranch=1 \
    file://cluster-ui.service \
    file://sigma-racer-wingman-ui.env \
    file://sigma-racer-wingman-ui-qemu.env \
"

UI_ENV = "${@bb.utils.contains('MACHINE', 'sigma-racer-wingman-qemu', 'sigma-racer-wingman-ui-qemu.env', 'sigma-racer-wingman-ui.env', d)}"

SRCREV = "1efb81d00b561b9104b6536fb9733c2eef62ebbb"

S = "${WORKDIR}/git"

DEPENDS += " \
    virtual/libgbm \
    libdrm \
    virtual/libgl \
    virtual/libgles2 \
    virtual/egl \
    fontconfig \
    freetype \
    libxkbcommon \
    wayland-native \
"

# Slint FemtoVG + Wayland (via winit) on i.MX Vivante
export SLINT_BACKEND = "femtovg"
export RUSTFLAGS:append = " --cfg sigma_racer_wingman_embedded"

CARGO_BUILD_FLAGS:append = " --bin sigma-dash"

SYSTEMD_SERVICE:${PN} = "cluster-ui.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/sigma-dash ${D}${bindir}/sigma-dash

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/cluster-ui.service ${D}${systemd_system_unitdir}/cluster-ui.service
    install -d ${D}${sysconfdir}/sigma-racer-wingman
    install -m 0644 ${WORKDIR}/${UI_ENV} ${D}${sysconfdir}/sigma-racer-wingman/ui.env
}

FILES:${PN} += " \
    ${bindir}/sigma-dash \
    ${systemd_system_unitdir}/cluster-ui.service \
    ${sysconfdir}/sigma-racer-wingman/ui.env \
"

RDEPENDS:${PN} += " \
    weston \
    liberation-fonts \
    fontconfig \
"

RPROVIDES:${PN} += "sigma-dash"

# Requires meta-rust in bblayers.conf
