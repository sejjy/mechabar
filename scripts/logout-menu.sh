#!/usr/bin/env bash

# Check if wlogout is already running
if pgrep -x "wlogout" >/dev/null; then
  pkill -x "wlogout"
  exit 0
fi

# File paths
config="$HOME/.config/wlogout"
layout="${config}/layout"
style="${config}/style.css"

# Check if required configuration files exist
if [ ! -f "${layout}" ] || [ ! -f "${style}" ]; then
  echo "ERROR: Required configuration files not found."
  exit 1
fi

# Get monitor information
width=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
height=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
scale=$(hyprctl -j monitors | jq '.[] | select(.focused == true) | .scale' | sed 's/\.//')

# Calculate margins
export x_margin=$((width * 39 / scale))
export y_margin=$((height * 21 / scale))

stylesheet=$(envsubst <"$style")

# Launch wlogout
wlogout -b 2 -c 0 -r 0 -m 0 --layout "${layout}" --css <(echo "${stylesheet}") --protocol layer-shell
