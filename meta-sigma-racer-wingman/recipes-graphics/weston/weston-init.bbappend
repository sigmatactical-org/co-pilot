FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Use Sigma Racer Wingman Weston kiosk config (Wayland-only — no Xwayland)
PACKAGECONFIG:remove = "xwayland"
INITSCRIPT_PARAMS = "defaults 09"

SRC_URI:append:sigma-racer-wingman-qemu = " file://weston-qemu.service "

SYSTEMD_SERVICE:${PN}:remove:sigma-racer-wingman-qemu = "weston.socket"

do_install:append:sigma-racer-wingman-qemu() {
    install -m 0644 ${WORKDIR}/weston-qemu.service ${D}${systemd_system_unitdir}/weston.service
    rm -f ${D}${systemd_system_unitdir}/weston.socket
}

do_install:append() {
    if [ -f ${D}${sysconfdir}/xdg/weston/weston.ini ]; then
        rm -f ${D}${sysconfdir}/xdg/weston/weston.ini
    fi
    ln -sf sigma-racer-wingman.ini ${D}${sysconfdir}/xdg/weston/weston.ini
}

RDEPENDS:${PN} += "sigma-racer-wingman-services"
