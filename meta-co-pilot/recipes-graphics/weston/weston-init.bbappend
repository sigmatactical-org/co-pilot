FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Use Co-Pilot Weston kiosk config (Wayland-only — no Xwayland)
PACKAGECONFIG:remove = "xwayland"
INITSCRIPT_PARAMS = "defaults 09"

SRC_URI:append:co-pilot-qemu = " file://weston-qemu.service "

SYSTEMD_SERVICE:${PN}:remove:co-pilot-qemu = "weston.socket"

do_install:append:co-pilot-qemu() {
    install -m 0644 ${WORKDIR}/weston-qemu.service ${D}${systemd_system_unitdir}/weston.service
    rm -f ${D}${systemd_system_unitdir}/weston.socket
}

do_install:append() {
    if [ -f ${D}${sysconfdir}/xdg/weston/weston.ini ]; then
        rm -f ${D}${sysconfdir}/xdg/weston/weston.ini
    fi
    ln -sf co-pilot.ini ${D}${sysconfdir}/xdg/weston/weston.ini
}

RDEPENDS:${PN} += "co-pilot-services"
