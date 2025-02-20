#!/usr/bin/env bash

WAYBAR_THEME_FILE="$HOME/.config/waybar/theme.css"

# Check if the theme file exists
if [[ -f "$WAYBAR_THEME_FILE" ]]; then
  # Read the first line and extract the theme name
  current_theme=$(head -n 1 "$WAYBAR_THEME_FILE" | sed -E 's|/\* *(.*) *\*/|\1|')
else
  current_theme="Unknown"
fi

tooltip="Theme: $current_theme"
tooltip+="\nStyle: Classic" # hard-coded for now

# Tooltip
echo "{\"tooltip\": \"$tooltip\"}"
