# Common recipe for Sigma Racer Wingman placeholder daemons until full implementations land.
# Replace with real Rust/C++ service recipes as subsystems mature.

SUMMARY = "Sigma Racer Wingman ${SIGMA_RACER_WINGMAN_SERVICE_NAME} daemon (stub)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit systemd

SIGMA_RACER_WINGMAN_SERVICE_NAME ??= "service"

SRC_URI = "file://${SIGMA_RACER_WINGMAN_SERVICE_NAME}.service \
           file://${SIGMA_RACER_WINGMAN_SERVICE_NAME}.sh \
          "

S = "${WORKDIR}"

do_compile() {
    :
}

do_install() {
    install -d ${D}${bindir}
    install -d ${D}${systemd_system_unitdir}
    install -m 0755 ${WORKDIR}/${SIGMA_RACER_WINGMAN_SERVICE_NAME}.sh ${D}${bindir}/sigma-racer-wingman-${SIGMA_RACER_WINGMAN_SERVICE_NAME}
    install -m 0644 ${WORKDIR}/${SIGMA_RACER_WINGMAN_SERVICE_NAME}.service ${D}${systemd_system_unitdir}/${SIGMA_RACER_WINGMAN_SERVICE_NAME}.service
}

SYSTEMD_SERVICE:${PN} = "${SIGMA_RACER_WINGMAN_SERVICE_NAME}.service"
SYSTEMD_AUTO_ENABLE = "enable"

FILES:${PN} = " \
    ${bindir}/sigma-racer-wingman-${SIGMA_RACER_WINGMAN_SERVICE_NAME} \
    ${systemd_system_unitdir}/${SIGMA_RACER_WINGMAN_SERVICE_NAME}.service \
"
