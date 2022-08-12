#!/bin/sh
# usage: yammountmtp.sh [device path to mount]
simple-mtpfs ~/MTPDevice && udisksctl mount -b $1
