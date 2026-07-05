SUMMARY = "Sigma Racer Wingman platform integration (Weston kiosk, data paths, defaults)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://weston.ini \
    file://weston-qemu.ini \
    file://sigmaracer-wingman-weston.sh \
    file://sigmaracer-wingman-tmpfiles.conf \
    file://sigmaracer-wingman-fstab.data \
    file://sigmaracer-wingman-ui.target \
"

S = "${WORKDIR}"

WESTON_INI = "${@bb.utils.contains('MACHINE', 'sigmaracer-wingman-qemu', 'weston-qemu.ini', 'weston.ini', d)}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "sigmaracer-wingman-ui.target"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${sysconfdir}/xdg/weston
    install -m 0644 ${WORKDIR}/${WESTON_INI} ${D}${sysconfdir}/xdg/weston/sigmaracer-wingman.ini

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/sigmaracer-wingman-weston.sh ${D}${bindir}/sigmaracer-wingman-weston

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/sigmaracer-wingman-tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/sigmaracer-wingman.conf

    install -d ${D}${sysconfdir}/sigmaracer-wingman
    install -m 0644 ${WORKDIR}/sigmaracer-wingman-fstab.data ${D}${sysconfdir}/sigmaracer-wingman/fstab.data

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/sigmaracer-wingman-ui.target ${D}${systemd_system_unitdir}/sigmaracer-wingman-ui.target
}

FILES:${PN} = " \
    ${sysconfdir}/xdg/weston/sigmaracer-wingman.ini \
    ${bindir}/sigmaracer-wingman-weston \
    ${sysconfdir}/tmpfiles.d/sigmaracer-wingman.conf \
    ${sysconfdir}/sigmaracer-wingman/fstab.data \
    ${systemd_system_unitdir}/sigmaracer-wingman-ui.target \
"

RDEPENDS:${PN} += "weston weston-init instrumentation"
