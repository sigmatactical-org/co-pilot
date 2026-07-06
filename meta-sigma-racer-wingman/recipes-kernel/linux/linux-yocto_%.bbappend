FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:sigma-racer-wingman-qemu = " file://can-vcan.cfg"
