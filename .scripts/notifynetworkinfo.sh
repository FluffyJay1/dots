#!/bin/sh
output=$(echo "$(wpa_cli status)" | awk -F '=' '
{
  switch ($1) {
  case "ssid":
    print "Network: " $2
    break
  case "ip_address":
    print "Local IP: " $2
    break
  }
}
')

output="$output
Public IP: $(dig +short txt ch whoami.cloudflare @1.0.0.1 | sed 's/"//g')"

vnstatline=$(vnstat -5 1 | head -7 | tail -1)
vnstattime=$(echo $vnstatline | awk '{print $1}')
vnstatavg=$(echo $vnstatline | awk -F '|' '{print $4}' | xargs)
output="$output
Avg traffic since $vnstattime: $vnstatavg"

notify-send -u low -t 10000 "$output"
