# Wayland / Weston kiosk configuration for instrument cluster display

DISTRO_FEATURES:append = " wayland"

# Weston runs on tty7 in kiosk mode; cluster UI is launched via systemd
PACKAGECONFIG:append:pn-weston = " kiosk systemd"

# Slint uses FemtoVG with OpenGL ES on embedded targets
PREFERRED_RPROVIDER_libEGL = "libegl-imx"
PREFERRED_RPROVIDER_libGLESv2 = "libgles-imx"

# Font rendering for Slint UI
IMAGE_INSTALL:append = " \
    fontconfig \
    fontconfig-utils \
    liberation-fonts \
    harfbuzz \
    freetype \
"
