#!/bin/sh
exec systemd-cat -t co-pilot-gps sh -c 'while true; do sleep 3600; done'
