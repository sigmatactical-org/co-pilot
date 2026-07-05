SUMMARY = "Sigma Racer Wingman platform integration (Weston kiosk, data paths, defaults)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://weston.ini \
    file://weston-qemu.ini \
    file://sigma-racer-wingman-weston.sh \
    file://sigma-racer-wingman-tmpfiles.conf \
    file://sigma-racer-wingman-fstab.data \
    file://sigma-racer-wingman-ui.target \
"

S = "${WORKDIR}"

WESTON_INI = "${@bb.utils.contains('MACHINE', 'sigma-racer-wingman-qemu', 'weston-qemu.ini', 'weston.ini', d)}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "sigma-racer-wingman-ui.target"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${sysconfdir}/xdg/weston
    install -m 0644 ${WORKDIR}/${WESTON_INI} ${D}${sysconfdir}/xdg/weston/sigma-racer-wingman.ini

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/sigma-racer-wingman-weston.sh ${D}${bindir}/sigma-racer-wingman-weston

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/sigma-racer-wingman-tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/sigma-racer-wingman.conf

    install -d ${D}${sysconfdir}/sigma-racer-wingman
    install -m 0644 ${WORKDIR}/sigma-racer-wingman-fstab.data ${D}${sysconfdir}/sigma-racer-wingman/fstab.data

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/sigma-racer-wingman-ui.target ${D}${systemd_system_unitdir}/sigma-racer-wingman-ui.target
}

FILES:${PN} = " \
    ${sysconfdir}/xdg/weston/sigma-racer-wingman.ini \
    ${bindir}/sigma-racer-wingman-weston \
    ${sysconfdir}/tmpfiles.d/sigma-racer-wingman.conf \
    ${sysconfdir}/sigma-racer-wingman/fstab.data \
    ${systemd_system_unitdir}/sigma-racer-wingman-ui.target \
"

RDEPENDS:${PN} += "weston weston-init instrumentation"
