#!/bin/sh
# usage: changebrightness.sh [inc/dec]
min=10 # min brightness
amount=15
current=$(xbacklight -ctrl intel_backlight -get)
case $1 in
  inc)
    next=$((current + amount))
    ;;
  dec)
    next=$((current - amount))
    [ $next -lt $min ] && next=$min
    ;;
esac

xbacklight -ctrl intel_backlight -set $next -fps 30 -time 100
