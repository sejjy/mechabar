#!/bin/bash
# Ensure nmcli is installed
if ! command -v nmcli &> /dev/null
then
    echo "nmcli could not be found"
    exit
fi

# Get the list of available Wi-Fi networks
networks=$(nmcli -f SSID device wifi list | tail -n +2)

# Show networks in a menu using rofi
selected=$(echo "$networks" | rofi -dmenu -i -p "Select Wi-Fi Network")

# If a network was selected, connect to it
if [ -n "$selected" ]; then
    nmcli device wifi connect "$selected"
fi
