SUMMARY = "Sigma Racer Wingman SocketCAN interface setup"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

CAN_SETUP_SCRIPT = "${@bb.utils.contains('MACHINE', 'sigma-racer-wingman-qemu', 'can-setup-vcan.sh', 'can-setup-flexcan.sh', d)}"

SRC_URI = " \
    file://${CAN_SETUP_SCRIPT} \
    file://sigma-racer-wingman-can-setup.service \
"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "sigma-racer-wingman-can-setup.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${libdir}/sigma-racer-wingman
    install -m 0755 ${WORKDIR}/${CAN_SETUP_SCRIPT} ${D}${libdir}/sigma-racer-wingman/can-setup.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/sigma-racer-wingman-can-setup.service \
        ${D}${systemd_system_unitdir}/sigma-racer-wingman-can-setup.service
}

FILES:${PN} = " \
    ${libdir}/sigma-racer-wingman/can-setup.sh \
    ${systemd_system_unitdir}/sigma-racer-wingman-can-setup.service \
"

RDEPENDS:${PN} += "iproute2 bash"
