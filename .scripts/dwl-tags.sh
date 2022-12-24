#!/usr/bin/env bash
#
# dwl-tags.sh - display dwl tags
# Accepts the output from my fork of dwl (https://github.com/FluffyJay1/dwl)
#
# USAGE: dwl-tags.sh 1
#
# REQUIREMENTS:
#  - inotifywait ( 'inotify-tools' on arch )
#  - Launch dwl with `dwl > ~.cache/dwltags` or change $fname
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
#         args: [1]
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
declare output title layout activetags selectedtags appid selmon
declare -a tags name
selmonind=0
nmons=0
# readonly fname="$HOME"/.cache/dwltags
fname=/tmp/dwl-tags-pipe
trap 'rm -f "$fname"' exit

_cycle() {
  tags=( "1" "2" "3" "4" "5" "6" "7" "8" "9" )

  # Name of tag (optional)
  # If there is no name, number are used
  #
  # Example:
  #  name=( "" "" "" "Media" )
  #  -> return "" "" "" "Media" 5 6 7 8 9)
  name=()

  printf -- '%s\n' "nmons|string|$nmons"
  printf -- '%s\n' "selmon|string|${selmon}"
  for tag in "${!tags[@]}"; do
    mask=$((1<<tag))

    tag_name="tag"
    # declare "${tag_name}_${tag}" # i have no idea why this line was here
    tagPrefix=${tag_name}_${tag}

    name[tag]="${name[tag]:-${tags[tag]}}"

    printf -- '%s\n' "${tagPrefix}|string|${name[tag]}"

    if (( "${selectedtags}" & mask )) 2>/dev/null; then
      printf -- '%s\n' "${tagPrefix}_focused|bool|true"
      # printf -- '%s\n' "title|string|${title}" why here
      # printf -- '%s\n' "appid|string|${appid}"
    else
      printf '%s\n' "${tagPrefix}_focused|bool|false"
    fi

    if (( "${activetags}" & mask )) 2>/dev/null; then
      printf -- '%s\n' "${tagPrefix}_occupied|bool|true"
    else
      printf -- '%s\n' "${tagPrefix}_occupied|bool|false"
    fi
  done

  pre=$(printf %${selmonind}s | tr " " "$monsym")
  post=$(printf %$((nmons - selmonind - 1))s | tr " " "$monsym")
  printf -- '%s\n' "premons|string|$pre"
  printf -- '%s\n' "monsym|string|$monsym"
  printf -- '%s\n' "postmons|string|$post"

  printf -- '%s\n' "title|string|${title}"
  printf -- '%s\n' "appid|string|${appid}"
  printf -- '%s\n' "layout|string|${layout}"
  printf -- '%s\n' ""
}

# Call the function here so the tags are displayed at dwl launch
# _cycle

while [[ ! -p "${fname}" ]]; do
  printf -- '%s\n' "You need to redirect dwl stdout to ${fname}" >&2
  sleep 0.2
done

# while true; do
while read output; do

  # debug print
  # printf -- '%s\n' "read ${output} from $fname" >&2

  # do not remove pipe after it connects
  # we do not have the need to facilitate multiple tty sessions
  # rm -f "${fname}" # do not do this, the pipe still exists, it's just no longer named

  # Get info from the file
  if [ "$output" = cycle ]; then
    _cycle
    nmons=0
    selmonind=0
    activetags=0
    continue
  fi
  tokens=( $output ) # (MONITOR INFO x)
  case ${tokens[1]} in
    selmon) # x = SELECTED?1/0
      selected=${tokens[@]:2}
      if [ $selected = 1 ]; then
        selmon=${tokens[0]}
        selmonind=$nmons
        isselmon=true
      else
        isselmon=false
      fi
      nmons=$((nmons + 1))
      ;;
    title) # x = TITLE_OF_FOCUSED_CLIENT...
      [ $isselmon = true ] || continue
      title=${tokens[@]:2}
      ;;
    appid) # x = APPID_OF_FOCUSED_CLIENT...
      [ $isselmon = true ] || continue
      appid=${tokens[@]:2}
      ;;
    tags) # x = ACTIVE_TAGS SELECTED_TAGS TAGS_OF_FOCUSED_CLIENT URGENT_TAGS
      activetags=$((activetags | ${tokens[2]}))
      [ $isselmon = true ] || continue
      selectedtags=${tokens[3]}
      ;;
    layout) # x = LAYOUT...
      [ $isselmon = true ] || continue
      layout=${tokens[@]:2}
      ;;
  esac

done < $fname

printf -- '%s\n' "exiting dwl-tags.sh" >&2

unset -v output title layout activetags selectedtags selmon
unset -v tags name

