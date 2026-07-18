# Build the Sigma Racer Wingman HMP overlay against the NXP linux-imx BSP
# kernel (the imx8mp machine's virtual/kernel provider — see the distro's
# PREFERRED_PROVIDER_virtual/kernel). The overlay enables the Cortex-M7
# remoteproc node so Linux can load the sidearm safety-core firmware; it is
# applied by U-Boot (boot.cmd) and rides in the boot FAT via IMAGE_BOOT_FILES.
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:sigma-racer-wingman-imx8mp = " file://sigma-racer-wingman-hmp.dts"

# Compile the overlay directly with the kernel's freshly-built dtc rather than
# via a kbuild dtb-y target: kbuild only builds .dtbo files registered in the
# freescale Makefile, and applies -@ conditionally. Preprocessing + dtc mirrors
# the kernel's own cmd_dtc (HOSTCC -E over scripts/dtc/include-prefixes) and
# keeps us off the kernel build graph entirely. -@ emits the __symbols__/
# __local_fixups__ the overlay's phandle targets (&mu, &clk, &flexcan1,
# &vdevbuffer ...) need to resolve at U-Boot `fdt apply` time.
do_compile:append:sigma-racer-wingman-imx8mp() {
    local ppdts="${B}/arch/arm64/boot/dts/freescale/.sigma-racer-wingman-hmp.pp.dts"
    local outdtbo="${B}/arch/arm64/boot/dts/freescale/sigma-racer-wingman-hmp.dtbo"
    ${CC} -E -nostdinc -undef -D__DTS__ -D__KERNEL__ -x assembler-with-cpp \
        -I ${S}/include -I ${S}/scripts/dtc/include-prefixes \
        -o "${ppdts}" ${WORKDIR}/sigma-racer-wingman-hmp.dts
    ${B}/scripts/dtc/dtc -@ -I dts -O dtb -o "${outdtbo}" "${ppdts}"
}

do_deploy:append:sigma-racer-wingman-imx8mp() {
    if [ -f ${B}/arch/arm64/boot/dts/freescale/sigma-racer-wingman-hmp.dtbo ]; then
        install -d ${DEPLOYDIR}/sigma-racer-wingman-overlays
        install -m 0644 ${B}/arch/arm64/boot/dts/freescale/sigma-racer-wingman-hmp.dtbo \
            ${DEPLOYDIR}/sigma-racer-wingman-overlays/
    fi
}
