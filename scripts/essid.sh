#!/bin/bash

# Get the current Wi-Fi ESSID and signal strength
essid=$(nmcli -t -f active,ssid dev wifi | awk -F: '/^yes/ {print $2}')
signal=$(nmcli -t -f active,signal dev wifi | awk -F: '/^yes/ {print $2}')

# If no ESSID is found, set a default value
if [ -z "$essid" ]; then
    essid="No Connection"
    signal=0
fi

# Determine Wi-Fi icon based on signal strength
if [ "$signal" -ge 80 ]; then
    icon="󰤨"  # Strong signal
elif [ "$signal" -ge 60 ]; then
    icon="󰤥"  # Good signal
elif [ "$signal" -ge 40 ]; then
    icon="󰤢"  # Weak signal
elif [ "$signal" -ge 20 ]; then
    icon="󰤟"  # Very weak signal
else
    icon="󰤮"  # No signal
fi

# Change "Wi-Fi" to "${essid}" to display network name
echo "{\"text\": \"${icon} Wi-Fi\", \"tooltip\": \"${icon} ESSID: ${essid}\"}"