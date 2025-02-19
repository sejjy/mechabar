#!/usr/bin/env bash

THEMES_DIR="$HOME/.config/waybar/themes"
THEME_FILE="$HOME/.config/waybar/theme.css"
CURRENT_THEME_FILE="$HOME/.config/waybar/current-theme"

if [[ ! -d "$THEMES_DIR" ]]; then
  echo "Error: Themes directory does not exist."
  exit 1
fi

# Get all themes
THEMES=("$THEMES_DIR"/*.css)
THEME_COUNT=${#THEMES[@]}

if [[ $THEME_COUNT -eq 0 ]]; then
  echo "Error: No themes found in $THEMES_DIR"
  exit 1
fi

# Get the current theme
if [[ -f "$CURRENT_THEME_FILE" ]]; then
  CURRENT_THEME=$(cat "$CURRENT_THEME_FILE")
else
  CURRENT_THEME=""
fi

NEXT_THEME_INDEX=0

for i in "${!THEMES[@]}"; do
  if [[ "${THEMES[$i]}" == "$CURRENT_THEME" ]]; then
    NEXT_THEME_INDEX=$(((i + 1) % THEME_COUNT))
    break
  fi
done

NEW_THEME="${THEMES[$NEXT_THEME_INDEX]}"

# Save the new theme
echo "$NEW_THEME" >"$CURRENT_THEME_FILE"

# Apply new theme
cp "$NEW_THEME" "$THEME_FILE"

# Restart Waybar to apply changes
killall waybar || true
nohup waybar >/dev/null 2>&1 &
