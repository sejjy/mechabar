#!/usr/bin/env bash

WAYBAR_THEME_FILE="$HOME/.config/waybar/theme.css"

# Check which theme is currently applied
if [[ -L "$WAYBAR_THEME_FILE" ]]; then
  current_theme=$(basename "$(readlink "$WAYBAR_THEME_FILE")" .css)
else
  current_theme="Unknown"
fi

# Format theme name: "theme-name" -> "Theme Name"
formatted_theme_name=$(echo "$current_theme" | awk -F- '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')

tooltip="Theme: $formatted_theme_name"
tooltip+="\nStyle: Classic" # hard-coded for now

# Tooltip
echo "{\"tooltip\": \"$tooltip\"}"
