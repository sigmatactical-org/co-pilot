#!/bin/sh
# Bring up physical SocketCAN (FlexCAN on i.MX 8M Plus EVK).
set -eu

IFACE="${SIGMA_RACER_WINGMAN_CAN_IFACE:-can0}"
BITRATE="${SIGMA_RACER_WINGMAN_CAN_BITRATE:-1000000}"

if ! ip link show "$IFACE" >/dev/null 2>&1; then
    echo "can-setup: interface $IFACE not found" >&2
    exit 1
fi

ip link set "$IFACE" down 2>/dev/null || true
ip link set "$IFACE" type can bitrate "$BITRATE" fd on
ip link set "$IFACE" up
