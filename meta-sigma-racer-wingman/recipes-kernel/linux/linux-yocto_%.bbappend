FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# linux-yocto is the kernel only for the QEMU machine (the imx8mp machine uses
# the NXP linux-imx BSP — see the distro PREFERRED_PROVIDER_virtual/kernel and
# linux-imx_%.bbappend, which carries the Cortex-M7 HMP overlay).
COMPATIBLE_MACHINE:append = "|sigma-racer-wingman-qemu"

SRC_URI:append:sigma-racer-wingman-qemu = " file://can-vcan.cfg"
