FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Use Co-Pilot Weston kiosk config (Wayland-only — no Xwayland)
PACKAGECONFIG:remove = "xwayland"
INITSCRIPT_PARAMS = "defaults 09"

do_install:append() {
    if [ -f ${D}${sysconfdir}/xdg/weston/weston.ini ]; then
        rm -f ${D}${sysconfdir}/xdg/weston/weston.ini
    fi
    ln -sf co-pilot.ini ${D}${sysconfdir}/xdg/weston/weston.ini
}

RDEPENDS:${PN} += "co-pilot-services"
