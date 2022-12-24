#!/bin/sh
# usage: describeclient.sh <appid> <title> <tags> <monitor name> <floating> <urgent> <fullscreen>
# sends a notification with this info
output="$(printf "appid: %s\ntitle: %s\ntags (octal): %o\nmonitor: %s\nfloating: %s\nurgent: %s\nfullscreen: %s" "$1" "$2" "$3" "$4" "$5" "$6" "$7")"
notify-send -u low -t 10000 "$output"
