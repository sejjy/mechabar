#!/usr/bin/env bash

CURRENT_THEME_FILE="$HOME/.config/waybar/current-theme"

# Get the current theme
if [[ -f "$CURRENT_THEME_FILE" ]]; then
  CURRENT_THEME=$(cat "$CURRENT_THEME_FILE")
  CURRENT_THEME_NAME=$(basename "$CURRENT_THEME" | sed 's/\.css$//')

  # Format theme name: "theme-name" -> "Theme Name"
  FORMATTED_THEME_NAME=$(echo "$CURRENT_THEME_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
else
  FORMATTED_THEME_NAME="Unknown"
fi

# Module and tooltip
echo "{\"text\": \" 󰍜 \", \"tooltip\": \"Theme: $FORMATTED_THEME_NAME\"}"
