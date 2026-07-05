# Minimal Weston — compositor only; instrumentation is the sole UI client
# Keep shell-desktop (xdg_wm_base for winit clients); drop unused shells/protocols
PACKAGECONFIG:remove = "xwayland remoting pipewire shell-kiosk shell-fullscreen shell-ivi"
