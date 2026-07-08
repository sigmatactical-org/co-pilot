# sigma-racer-wingman-qemu needs a display backend for runqemu (gtk/sdl).
PACKAGECONFIG:append = " sdl"
DEPENDS:append = " libsdl2-native"

# glibc 2.41+ / Debian 13: avoid struct sched_attr redefinition in imx-qemu
FILESEXTRAPATHS:prepend := "${THISDIR}/qemu:"
SRC_URI:append = " file://0001-sched_attr-Do-not-define-for-glibc-2.41.patch"
