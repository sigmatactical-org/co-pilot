SUMMARY = "Sigma Racer Wingman vehicle signal abstraction daemon"
HOMEPAGE = "https://github.com/sigmatactical-org/sigma-instrumentation"
LICENSE = "MIT | Apache-2.0"
LIC_FILES_CHKSUM = " \
    file://LICENSE-MIT;md5=a082e45a87ea9bc152345be779914257 \
    file://LICENSE-APACHE;md5=d8b08026ec729e41461816aba7fc28c4 \
"

inherit cargo cargo-update-recipe-crates systemd externalsrc

EXTERNALSRC = "${SIGMA_INSTRUMENTATION_SRC}"

SRC_URI = " \
    git://github.com/sigmatactical-org/sigma-instrumentation.git;protocol=https;name=instrumentation;nobranch=1 \
    file://vehicle.service \
    file://sigma-racer-wingman-vehicle.env \
    file://sigma-racer-wingman-vehicle-qemu.env \
    file://sigma-racer-wingman-vehicle.tmpfiles.conf \
"

require ${THISDIR}/../sigma-instrumentation/sigma-instrumentation-crates.inc

SRCREV = "e81cd1206e2a23f6fbb9cae678616a47760467a3"

S = "${WORKDIR}/git"

VEHICLE_ENV = "${@bb.utils.contains('MACHINE', 'sigma-racer-wingman-qemu', 'sigma-racer-wingman-vehicle-qemu.env', 'sigma-racer-wingman-vehicle.env', d)}"

CARGO_BUILD_FLAGS:append = " -p vehicle-service --bin sigma-racer-wingman-vehicle --features can-socket"

SYSTEMD_SERVICE:${PN} = "vehicle.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/sigma-racer-wingman-vehicle ${D}${bindir}/sigma-racer-wingman-vehicle

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/vehicle.service ${D}${systemd_system_unitdir}/vehicle.service

    install -d ${D}${sysconfdir}/sigma-racer-wingman
    install -m 0644 ${WORKDIR}/${VEHICLE_ENV} ${D}${sysconfdir}/sigma-racer-wingman/vehicle.env

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/sigma-racer-wingman-vehicle.tmpfiles.conf ${D}${sysconfdir}/tmpfiles.d/sigma-racer-wingman-vehicle.conf
}

FILES:${PN} = " \
    ${bindir}/sigma-racer-wingman-vehicle \
    ${systemd_system_unitdir}/vehicle.service \
    ${sysconfdir}/sigma-racer-wingman/vehicle.env \
    ${sysconfdir}/tmpfiles.d/sigma-racer-wingman-vehicle.conf \
"

RDEPENDS:${PN} += " \
    bash \
    can-network \
"
