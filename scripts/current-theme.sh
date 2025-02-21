#!/usr/bin/env bash

CURRENT_THEME_FILE="$HOME/.config/waybar/themes/current-theme"

# Get the current theme
current_theme=$(cat "$CURRENT_THEME_FILE" 2>/dev/null || echo "")
current_theme_name="Default"

# Get the theme name
if [[ -n "$current_theme" ]]; then
  current_theme_name=$(basename "$current_theme" .css)

  # Convert "theme-name" to "Theme Name"
  formatted_theme_name="${current_theme_name//-/ }"
  formatted_theme_name=$(echo "$formatted_theme_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
else
  formatted_theme_name="Default"
fi

tooltip="Theme: $formatted_theme_name"
tooltip+="\nStyle: Classic" # hard-coded for now

# Tooltip
echo "{\"tooltip\": \"$tooltip\"}"
