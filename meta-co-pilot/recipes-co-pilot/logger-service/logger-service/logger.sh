#!/bin/sh
exec systemd-cat -t co-pilot-logger sh -c 'while true; do sleep 3600; done'
