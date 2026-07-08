FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Custom machine name inherits qemux86-64 but is not in upstream COMPATIBLE_MACHINE.
COMPATIBLE_MACHINE:append = "|sigma-racer-wingman-qemu"

SRC_URI:append:sigma-racer-wingman-qemu = " file://can-vcan.cfg"
