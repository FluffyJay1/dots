#!/bin/sh
# Outputs the current monitor config (likely configured by wdisplays) to a format usable by kanshi (or sway for that matter)
# depends on wlr-randr, but won't be very useful without wdisplays or kanshi

output=$(
wlr-randr | while IFS= read -r line; do
  # match [<output name> "<output description>"], convert to [output "<output name>"]
  # outputdesc=$(expr "'$line'" : '[^\s]\+ \(".*"\)')
  outputname=$(expr "$line" : '\([^\s]\+\) ".*"')
  if [ "$outputname" ]; then
    echo -n "\noutput $outputname"
    continue
  fi

  # match [  Enabled: <yes/no>], append either 'enable' or 'disable'
  enabled=$(expr "'$line'" : "'  Enabled: \(yes\|no\)'")
  case "$enabled" in
    yes)
      echo -n ' enable'
      continue
      ;;
    no)
      echo -n ' disable'
      continue;;
  esac

  # match [    <width>x<height> px, <refresh rate> Hz (...current)], append [mode <width>x<height>@<refresh rate>Hz]
  if expr "$line" : '    [0-9]\+x[0-9]\+ px, [0-9]\+\.[0-9]\+ Hz (.*current)' > /dev/null; then
    echo -n " mode $(echo "$line" | awk '{printf "%s@%sHz",$1,$3}')"
    continue
  fi

  # match [  Position: <x>,<y>], append [position <x>,<y>]
  position=$(expr "'$line'" : "'  Position: \([0-9]\+,[0-9]\+\)'")
  if [ "$position" ]; then
    echo -n " position $position"
    continue
  fi

  # match [  Transform: <transform>], append [transform <transform>]
  transform=$(expr "'$line'" : "'  Transform: \(.*\)'")
  if [ "$transform" ]; then
    echo -n " transform $transform"
    continue
  fi

  # match [  Scale: <scale>], append [scale <scale>]
  scale=$(expr "'$line'" : "'  Scale: \(.*\)'")
  if [ "$scale" ]; then
    echo -n " scale $scale"
    continue
  fi
done
)

# skip first line, it's always a newline
echo "$output" | tail -n +2
