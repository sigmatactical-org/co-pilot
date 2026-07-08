SUMMARY = "RAUC configuration for Sigma Racer Wingman A/B OTA updates"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://system.conf \
           file://sigma-racer-wingman-ca.cert.pem \
          "

S = "${WORKDIR}"

# The RAUC `compatible` string embeds the machine name, which differs per
# target, so this package must be rebuilt per machine.
PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install() {
    install -d ${D}${sysconfdir}/rauc
    install -m 0644 ${WORKDIR}/system.conf ${D}${sysconfdir}/rauc/system.conf
    # RAUC has no runtime variable expansion; bake the real MACHINE in now so the
    # on-device `compatible` matches the value stamped on update bundles.
    sed -i "s/@MACHINE@/${MACHINE}/g" ${D}${sysconfdir}/rauc/system.conf
    install -m 0644 ${WORKDIR}/sigma-racer-wingman-ca.cert.pem ${D}${sysconfdir}/rauc/ca.cert.pem
}

FILES:${PN} = "${sysconfdir}/rauc/"

RPROVIDES:${PN} += "virtual-rauc-conf"
RREPLACES:${PN} += "rauc-conf"
RCONFLICTS:${PN} += "rauc-conf"

RDEPENDS:${PN} += "rauc"
