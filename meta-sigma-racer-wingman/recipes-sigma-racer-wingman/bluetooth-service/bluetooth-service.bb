SUMMARY = "Sigma Racer Wingman bluetooth daemon"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

SRC_URI = "file://sigma-racer-wingman-bluetooth.service \
           file://sigma-racer-wingman-bluetooth.sh \
          "

S = "${WORKDIR}"

do_compile() {
    :
}

do_install() {
    install -d ${D}${bindir} ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/sigma-racer-wingman-bluetooth.sh ${D}${bindir}/sigma-racer-wingman-bluetooth
    install -m 0644 ${WORKDIR}/sigma-racer-wingman-bluetooth.service ${D}${systemd_system_unitdir}/sigma-racer-wingman-bluetooth.service
}

SYSTEMD_SERVICE:${PN} = "sigma-racer-wingman-bluetooth.service"
SYSTEMD_AUTO_ENABLE = "enable"

FILES:${PN} = " \
    ${bindir}/sigma-racer-wingman-bluetooth \
    ${systemd_system_unitdir}/sigma-racer-wingman-bluetooth.service \
"
