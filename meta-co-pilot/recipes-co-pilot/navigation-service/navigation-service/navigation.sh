#!/bin/sh
exec systemd-cat -t co-pilot-navigation sh -c 'while true; do sleep 3600; done'
