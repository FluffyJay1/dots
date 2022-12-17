#!/bin/sh
# the subprocess spawned by dwl
pipe=/tmp/dwl-tags-pipe

trap 'rm -f "$pipe"' exit # doesn't seem to do jack shit
gentoo-pipewire-launcher &
kanshi &
yambar &
$HOME/.azotebg &
foot --server &
[ -p $pipe ] || mkfifo $pipe
cp /dev/stdin $pipe
