#!/bin/sh
# usage: yamumountmtp.sh [device path to unmount]
fusermount -u ~/MTPDevice && udisksctl unmount -b $1
