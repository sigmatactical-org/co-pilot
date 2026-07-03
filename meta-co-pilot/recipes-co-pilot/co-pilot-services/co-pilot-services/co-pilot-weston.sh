#!/bin/sh
# Weston compositor for Co-Pilot — instrumentation (sigma-dash) is launched by cluster-ui.service
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run}"
exec weston --config=/etc/xdg/weston/co-pilot.ini --log=/var/log/weston.log
