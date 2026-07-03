SUMMARY = "RAUC configuration for Co-Pilot A/B OTA updates"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://system.conf \
           file://co-pilot-ca.cert.pem \
          "

S = "${WORKDIR}"

do_install() {
    install -d ${D}${sysconfdir}/rauc
    install -m 0644 ${WORKDIR}/system.conf ${D}${sysconfdir}/rauc/system.conf
    install -m 0644 ${WORKDIR}/co-pilot-ca.cert.pem ${D}${sysconfdir}/rauc/ca.cert.pem
}

FILES:${PN} = "${sysconfdir}/rauc/"

RDEPENDS:${PN} += "rauc"
