SUMMARY = "Co-Pilot platform integration (Weston kiosk, data paths, defaults)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://weston.ini \
    file://co-pilot-weston.sh \
    file://co-pilot-tmpfiles.conf \
    file://co-pilot-fstab.data \
    file://co-pilot-ui.target \
"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "co-pilot-ui.target"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${sysconfdir}/xdg/weston
    install -m 0644 ${WORKDIR}/weston.ini ${D}${sysconfdir}/xdg/weston/co-pilot.ini

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/co-pilot-weston.sh ${D}${bindir}/co-pilot-weston

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/co-pilot-tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/co-pilot.conf

    install -d ${D}${sysconfdir}/co-pilot
    install -m 0644 ${WORKDIR}/co-pilot-fstab.data ${D}${sysconfdir}/co-pilot/fstab.data

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/co-pilot-ui.target ${D}${systemd_system_unitdir}/co-pilot-ui.target
}

FILES:${PN} = " \
    ${sysconfdir}/xdg/weston/co-pilot.ini \
    ${bindir}/co-pilot-weston \
    ${sysconfdir}/tmpfiles.d/co-pilot.conf \
    ${sysconfdir}/co-pilot/fstab.data \
    ${systemd_system_unitdir}/co-pilot-ui.target \
"

RDEPENDS:${PN} += "weston weston-init instrumentation"
