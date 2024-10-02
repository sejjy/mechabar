#!/bin/bash

# Get the current Wi-Fi ESSID
essid=$(nmcli -t -f active,ssid dev wifi | awk -F: '/^yes/ {print $2}')

# If no ESSID is found, set a default value
if [ -z "$essid" ]; then
    essid="No Connection"
fi

# Output JSON format
echo "${essid}"