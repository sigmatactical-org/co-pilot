SUMMARY = "U-Boot A/B boot script for Sigma Racer Wingman (RAUC slot selection)"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://boot.cmd"

# Re-render when the machine's devicetree list changes.
do_compile[vardeps] += "KERNEL_DEVICETREE"

DEPENDS = "u-boot-mkimage-native"

COMPATIBLE_MACHINE = "sigma-racer-wingman-imx8mp"
PACKAGE_ARCH = "${MACHINE_ARCH}"

S = "${WORKDIR}"

inherit deploy

# First (only) dtb of the machine's KERNEL_DEVICETREE.
FDTFILE = "${@os.path.basename(d.getVar('KERNEL_DEVICETREE').split()[0])}"

do_compile() {
    # S == WORKDIR here, so render under a distinct name.
    sed "s|@FDTFILE@|${FDTFILE}|" ${WORKDIR}/boot.cmd > ${B}/boot.cmd.rendered
    mkimage -A arm64 -T script -C none -n "Sigma Racer Wingman A/B boot" \
        -d ${B}/boot.cmd.rendered ${B}/boot.scr
}

do_deploy() {
    install -m 0644 ${B}/boot.scr ${DEPLOYDIR}/boot.scr
}
addtask deploy after do_compile before do_build

# Nothing to package — the script rides in the boot partition via
# IMAGE_BOOT_FILES.
do_install[noexec] = "1"
PACKAGES = ""
