#!/bin/sh
exec systemd-cat -t co-pilot-diagnostics sh -c 'while true; do sleep 3600; done'
