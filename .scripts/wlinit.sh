#!/bin/sh
# the subprocess spawned by dwl
fname=/tmp/dwl-status

gentoo-pipewire-launcher &
kanshi &
yambar &
$HOME/.azotebg &

# oh man ipc time
# batch the status output from dwl until "cycle" is encountered, then make a single write to the tmp file
# the dwl-tags.sh script has code to read this file
cum=""
while read -r line; do
  if [ "$line" = "cycle" ]; then
    echo "$cum" > "$fname"
    cum=""
  else
    cum="${cum}$line\n"
  fi
done <&0

