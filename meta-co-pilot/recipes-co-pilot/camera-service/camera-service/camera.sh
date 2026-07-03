#!/bin/sh
exec systemd-cat -t co-pilot-camera sh -c 'while true; do sleep 3600; done'
