FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

COMPATIBLE_MACHINE:append = "|sigma-racer-wingman-qemu"
COMPATIBLE_MACHINE:append = "|sigma-racer-wingman-imx8mp"

SRC_URI:append:sigma-racer-wingman-qemu = " file://can-vcan.cfg"
SRC_URI:append:sigma-racer-wingman-imx8mp = " file://sigma-racer-wingman-hmp.dts"

do_configure:append:sigma-racer-wingman-imx8mp() {
    if [ -d ${S}/arch/arm64/boot/dts ]; then
        cp ${WORKDIR}/sigma-racer-wingman-hmp.dts ${S}/arch/arm64/boot/dts/
    fi
}

do_compile:append:sigma-racer-wingman-imx8mp() {
    if [ -d ${B}/arch/arm64/boot/dts ]; then
        oe_runmake -C ${B} arch/arm64/boot/dts/sigma-racer-wingman-hmp.dtbo \
            DTC_FLAGS="-@" 2>/dev/null || true
    fi
}

do_deploy:append:sigma-racer-wingman-imx8mp() {
    if [ -f ${B}/arch/arm64/boot/dts/sigma-racer-wingman-hmp.dtbo ]; then
        install -d ${DEPLOYDIR}/sigma-racer-wingman-overlays
        install -m 0644 ${B}/arch/arm64/boot/dts/sigma-racer-wingman-hmp.dtbo \
            ${DEPLOYDIR}/sigma-racer-wingman-overlays/
    fi
}
