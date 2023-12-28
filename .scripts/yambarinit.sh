#!/bin/sh

# get all display names
wlr-randr | awk '$0~/^[^\s]+ ".*"$/{print $1}' | while IFS= read -r display; do
  # take the yambar config as a template and make a new one
  tmpconfig=$(mktemp ".config/yambar/config.yml.$display.XXX")
  echo $tmpconfig
  sed -E "s/REPLACE_WITH_OUTPUT_NAME/$display/g" "$HOME/.config/yambar/config.yml" > "$tmpconfig"
  # start yambar on this display
  yambar --config="$tmpconfig" &
done
