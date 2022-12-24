#!/bin/sh
# usage: yamumountmtp.sh [device path to unmount]
# the udisksctl command is just to get it to toggle on yambar
fusermount -u ~/MTPDevice && udisksctl unmount -b $1
