#!/bin/sh
# the subprocess spawned by dwl
pipe=/tmp/dwl-tags-pipe

trap \"rm -f $pipe\" EXIT
gentoo-pipewire-launcher &
yambar &
$HOME/.azotebg &
foot --server &
[ -p $pipe ] || mkfifo $pipe
cp /dev/stdin $pipe
