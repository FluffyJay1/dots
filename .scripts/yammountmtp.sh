#!/bin/sh
# usage: yammountmtp.sh [device path to mount]
# the udisksctl command is just to get it to toggle on yambar
simple-mtpfs ~/MTPDevice && udisksctl mount -b $1
