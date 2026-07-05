SUMMARY = "Sigma Racer Wingman vehicle signal abstraction daemon"
HOMEPAGE = "https://github.com/sigmatactical-org/sigmaracer-instrumentation"
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-MIT;md5=a082e45a87ea9bc152345be779914257 \
    file://LICENSE-APACHE;md5=d8b08026ec729e41461816aba7fc28c4 \
"

inherit cargo cargo-update-recipe-crates systemd externalsrc

EXTERNALSRC = "${SIGMA_INSTRUMENTATION_SRC}"

SRC_URI = " \
    git://github.com/sigmatactical-org/sigmaracer-instrumentation.git;protocol=https;branch=main;name=instrumentation;nobranch=1 \
    file://vehicle.service \
    file://sigmaracer-wingman-vehicle.env \
    file://sigmaracer-wingman-vehicle.tmpfiles.conf \
"

require ${THISDIR}/../sigmaracer-instrumentation/sigmaracer-instrumentation-crates.inc

SRCREV = "e81cd1206e2a23f6fbb9cae678616a47760467a3"

S = "${WORKDIR}/git"

CARGO_BUILD_FLAGS:append = " -p vehicle-service --bin sigmaracer-wingman-vehicle"

SYSTEMD_SERVICE:${PN} = "vehicle.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/sigmaracer-wingman-vehicle ${D}${bindir}/sigmaracer-wingman-vehicle

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/vehicle.service ${D}${systemd_system_unitdir}/vehicle.service

    install -d ${D}${sysconfdir}/sigmaracer-wingman
    install -m 0644 ${WORKDIR}/sigmaracer-wingman-vehicle.env ${D}${sysconfdir}/sigmaracer-wingman/vehicle.env

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/sigmaracer-wingman-vehicle.tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/sigmaracer-wingman-vehicle.conf
}

FILES:${PN} = " \
    ${bindir}/sigmaracer-wingman-vehicle \
    ${systemd_system_unitdir}/vehicle.service \
    ${sysconfdir}/sigmaracer-wingman/vehicle.env \
    ${sysconfdir}/tmpfiles.d/sigmaracer-wingman-vehicle.conf \
"

RDEPENDS:${PN} += " \
    bash \
"
