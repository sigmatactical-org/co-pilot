#!/bin/sh
exec systemd-cat -t co-pilot-bluetooth sh -c 'while true; do sleep 3600; done'
