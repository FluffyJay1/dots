#!/bin/sh
# usage: focusmon.sh <output name>
# script that gets run whenever focusing a monitor via hotkeys
notify-send -u low -t 100 "Selected monitor $1"
