#!/bin/sh
#
# dwl-tags.sh - display dwl tags
# Accepts the output from my fork of dwl (https://github.com/FluffyJay1/dwl)
#
# USAGE: dwl-tags.sh <monitor name>
#
# REQUIREMENTS:
#  - inotifywait ( 'inotify-tools' on arch )
#  - Launch dwl with `dwl > /tmp/dwl-status` or change $fname
#
# TAGS:
#  Name              Type    Return
#  ----------------------------------------------------
#  {tag_N}           string  dwl tags name
#  {tag_N_occupied}  bool    dwl tags state occupied
#  {tag_N_focused}   bool    dwl tags state focused
#  {layout}          string  dwl layout
#  {title}           string  client title
#  {appid}           string  client appid
#  {selmon}          string  selected monitor name
#
# Now the fun part
#
# Exemple configuration:
#
#     - script:
#         path: /absolute/path/to/dwl-tags.sh
#         args: ["monitor_name"]
#         anchors:
#           - occupied: &occupied {foreground: 57bbf4ff}
#           - focused: &focused {foreground: fc65b0ff}
#           - default: &default {foreground: d2ccd6ff}
#         content:
#           - map:
#               margin: 4
#               tag: tag_0_occupied
#               values:
#                 true:
#                   map:
#                     tag: tag_0_focused
#                     values:
#                       true: {string: {text: "{tag_0}", <<: *focused}}
#                       false: {string: {text: "{tag_0}", <<: *occupied}}
#                 false:
#                   map:
#                     tag: tag_0_focused
#                     values:
#                       true: {string: {text: "{tag_0}", <<: *focused}}
#                       false: {string: {text: "{tag_0}", <<: *default}}
#           ...
#           ... 
#          ...
#           - map:
#               margin: 4
#               tag: tag_8_occupied
#               values:
#                 true:
#                   map:
#                     tag: tag_8_focused
#                     values:
#                       true: {string: {text: "{tag_8}", <<: *focused}}
#                       false: {string: {text: "{tag_8}", <<: *occupied}}
#                 false:
#                   map:
#                     tag: tag_8_focused
#                     values:
#                       true: {string: {text: "{tag_8}", <<: *focused}}
#                       false: {string: {text: "{tag_8}", <<: *default}}
#           - list:
#               spacing: 3
#               items:
#                   - string: {text: "{layout}"}
#                   - string: {text: "{title}"}

monsym='/' # symbol to represent a monitor
# Variables
selmonind=0
nmons=0
# readonly fname="$HOME"/.cache/dwltags
fname=/tmp/dwl-status
monname=$1

_cycle() {
  printf -- '%s\n' "nmons|string|$nmons"
  tag=0
  for tagname in 1 2 3 4 5 6 7 8 9; do # optional: replace with name of tag (e.g. replace 9 with "firefox")
    mask=$((1<<tag))

    tag_name="tag"
    # declare "${tag_name}_${tag}" # i have no idea why this line was here
    tagPrefix=${tag_name}_${tag}

    printf -- '%s\n' "${tagPrefix}|string|${tagname}"

    if [ "$((selectedtags & mask))" -ne 0 ]; then
      printf -- '%s\n' "${tagPrefix}_focused|bool|true"
    else
      printf '%s\n' "${tagPrefix}_focused|bool|false"
    fi

    if [ "$((activetags & mask))" -ne 0 ]; then
      printf -- '%s\n' "${tagPrefix}_occupied|bool|true"
    else
      printf -- '%s\n' "${tagPrefix}_occupied|bool|false"
    fi
    tag=$((tag+1))
  done

  printf -- '%s\n' "selmonrelative|int|$((selmonind - curmonind))"
  printf -- '%s\n' "monsym|string|$monsym"
  printf -- '%s\n' "postmons|string|$post"

  printf -- '%s\n' "title|string|${title}"
  printf -- '%s\n' "appid|string|${appid}"
  printf -- '%s\n' "layout|string|${layout}"
  printf -- '%s\n' ""
}

# Call the function here so the tags are displayed at dwl launch
# _cycle

while [ ! -e "${fname}" ]; do
  printf -- '%s\n' "You need to redirect dwl stdout to ${fname}" >&2
  sleep 0.2
done

while true; do
  nmons=0
  selmonind=0
  activetags=0
  # for some reason you have to read the entire file at once or else it might enter an inconsistent state
  # because race conditions or something
  status="$(cat "$fname")"
  while read line; do
    set -- $line # (MONITOR INFO x)
    case $2 in
      selmon) # x = SELECTED?1/0
        if [ $1 = $monname ] ; then
          curmonind=$nmons
        fi
        if [ "$3" = 1 ]; then
          selmon=$1
          selmonind=$nmons
        fi
        nmons=$((nmons + 1))
        ;;
      title) # x = TITLE_OF_FOCUSED_CLIENT...
        [ $1 = $monname ] || continue
        shift 2
        title="$@"
        ;;
      appid) # x = APPID_OF_FOCUSED_CLIENT...
        [ $1 = $monname ] || continue
        shift 2
        appid="$@"
        ;;
      tags) # x = ACTIVE_TAGS SELECTED_TAGS TAGS_OF_FOCUSED_CLIENT URGENT_TAGS
        [ $1 = $monname ] || continue
        activetags=$3
        selectedtags=$4
        ;;
      layout) # x = LAYOUT...
        [ $1 = $monname ] || continue
        shift 2
        layout="$@"
        ;;
    esac
  done << EOF
$status
EOF
  _cycle
  inotifywait -qq --event close_write "$fname"
done

printf -- '%s\n' "exiting dwl-tags.sh" >&2
