#!/bin/sh
exec systemd-cat -t co-pilot-ota sh -c 'while true; do sleep 3600; done'
