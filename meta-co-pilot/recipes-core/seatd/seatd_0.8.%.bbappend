FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://seatd.service "

inherit systemd

SYSTEMD_SERVICE:${PN} = "seatd.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install:append() {
    install -Dm644 ${WORKDIR}/seatd.service ${D}${systemd_system_unitdir}/seatd.service
}
