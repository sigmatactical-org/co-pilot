# Common recipe for Co-Pilot placeholder daemons until full implementations land.
# Replace with real Rust/C++ service recipes as subsystems mature.

SUMMARY = "Co-Pilot ${CO_PILOT_SERVICE_NAME} daemon (stub)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

CO_PILOT_SERVICE_NAME ??= "service"

SRC_URI = "file://${CO_PILOT_SERVICE_NAME}.service \
           file://${CO_PILOT_SERVICE_NAME}.sh \
          "

S = "${WORKDIR}"

do_compile() {
    :
}

do_install() {
    install -d ${D}${bindir}
    install -d ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/${CO_PILOT_SERVICE_NAME}.sh ${D}${bindir}/co-pilot-${CO_PILOT_SERVICE_NAME}
    install -m 0644 ${WORKDIR}/${CO_PILOT_SERVICE_NAME}.service ${D}${systemd_system_unitdir}/${CO_PILOT_SERVICE_NAME}.service
}

SYSTEMD_SERVICE:${PN} = "${CO_PILOT_SERVICE_NAME}.service"
SYSTEMD_AUTO_ENABLE = "enable"

FILES:${PN} = " \
    ${bindir}/co-pilot-${CO_PILOT_SERVICE_NAME} \
    ${systemd_system_unitdir}/${CO_PILOT_SERVICE_NAME}.service \
"
