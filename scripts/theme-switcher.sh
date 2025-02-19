#!/usr/bin/env bash

WAYBAR_THEMES_DIR="$HOME/.config/waybar/themes"
WAYBAR_THEME_FILE="$HOME/.config/waybar/theme.css"
ROFI_THEMES_DIR="$HOME/.config/rofi/themes"
ROFI_THEME_FILE="$HOME/.config/rofi/theme.rasi"
CURRENT_THEME_FILE="$HOME/.config/waybar/current-theme"

if [[ ! -d "$WAYBAR_THEMES_DIR" ]]; then
  echo "Error: $WAYBAR_THEMES_DIR not found"
  exit 1
elif [[ ! -d "$ROFI_THEMES_DIR" ]]; then
  echo "Error: $ROFI_THEMES_DIR not found"
  exit 1
fi

# Get all themes
WAYBAR_THEMES=("$WAYBAR_THEMES_DIR"/*.css)
WAYBAR_THEME_COUNT=${#WAYBAR_THEMES[@]}
ROFI_THEMES=("$ROFI_THEMES_DIR"/*.rasi)
ROFI_THEME_COUNT=${#ROFI_THEMES[@]}

if [[ $WAYBAR_THEME_COUNT -eq 0 ]]; then
  echo "Error: No themes found in $WAYBAR_THEMES_DIR"
  exit 1
elif [[ $ROFI_THEME_COUNT -eq 0 ]]; then
  echo "Error: No themes found in $ROFI_THEMES_DIR"
  exit 1
fi

# Get the current theme
if [[ -f "$CURRENT_THEME_FILE" ]]; then
  CURRENT_THEME=$(cat "$CURRENT_THEME_FILE")
else
  CURRENT_THEME=""
fi

NEXT_THEME_INDEX=0

for i in "${!WAYBAR_THEMES[@]}"; do
  if [[ "${WAYBAR_THEMES[$i]}" == "$CURRENT_THEME" ]]; then
    NEXT_THEME_INDEX=$(((i + 1) % WAYBAR_THEME_COUNT))
    break
  fi
done

for i in "${!ROFI_THEMES[@]}"; do
  if [[ "${ROFI_THEMES[$i]}" == "$CURRENT_THEME" ]]; then
    NEXT_THEME_INDEX=$(((i + 1) % ROFI_THEME_COUNT))
    break
  fi
done

NEW_WAYBAR_THEME="${WAYBAR_THEMES[$NEXT_THEME_INDEX]}"
NEW_ROFI_THEME="${ROFI_THEMES[$NEXT_THEME_INDEX]}"

# Save the new theme
echo "$NEW_WAYBAR_THEME" >"$CURRENT_THEME_FILE"

# Apply new theme
cp "$NEW_WAYBAR_THEME" "$WAYBAR_THEME_FILE"
cp "$NEW_ROFI_THEME" "$ROFI_THEME_FILE"

# Restart Waybar to apply changes
killall waybar || true
nohup waybar >/dev/null 2>&1 &
