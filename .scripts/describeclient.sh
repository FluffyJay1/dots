#!/bin/sh
# usage: describeclient.sh <appid> <title> <tags> <monitor name> <floating> <urgent> <fullscreen> <x11>
# sends a notification with this info
output="$(printf "appid: %s\ntitle: %s\ntags (octal): %o\nmonitor: %s\nfloating: %s\nurgent: %s\nfullscreen: %s\nx11: %s" "$@")"
notify-send -u low -t 10000 "$output"
