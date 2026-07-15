SUMMARY = "RAUC configuration for Sigma Racer Wingman A/B OTA updates"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://system.conf \
           file://sigma-racer-wingman-ca.cert.pem \
          "
SRC_URI:append:sigma-racer-wingman-imx8mp = " file://fw_env.config"

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

# Where fw_setenv finds the U-Boot environment (RAUC's uboot backend).
do_install:append:sigma-racer-wingman-imx8mp() {
    install -m 0644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}

FILES:${PN} = "${sysconfdir}/rauc/"
FILES:${PN}:append:sigma-racer-wingman-imx8mp = " ${sysconfdir}/fw_env.config"

RPROVIDES:${PN} += "virtual-rauc-conf"
RREPLACES:${PN} += "rauc-conf"
RCONFLICTS:${PN} += "rauc-conf"

RDEPENDS:${PN} += "rauc"
