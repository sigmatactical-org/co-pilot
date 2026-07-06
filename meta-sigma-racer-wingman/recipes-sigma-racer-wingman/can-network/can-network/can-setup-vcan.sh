#!/bin/sh
# Bring up virtual CAN for QEMU / bench testing.
set -eu

IFACE="${SIGMA_RACER_WINGMAN_CAN_IFACE:-vcan0}"

if ip link show "$IFACE" >/dev/null 2>&1; then
    ip link set "$IFACE" up
    exit 0
fi

ip link add dev "$IFACE" type vcan
ip link set "$IFACE" up
