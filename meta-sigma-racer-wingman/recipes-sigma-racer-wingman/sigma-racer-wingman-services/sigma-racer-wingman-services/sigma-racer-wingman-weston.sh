#!/bin/sh
# Weston compositor for Sigma Racer Wingman — instrumentation (sigma-dash) is launched by cluster-ui.service
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run}"
exec weston --config=/etc/xdg/weston/sigma-racer-wingman.ini --log=/var/log/weston.log
