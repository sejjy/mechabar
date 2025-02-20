#!/usr/bin/env bash

WAYBAR_THEMES_DIR="$HOME/.config/waybar/themes"
WAYBAR_THEME_FILE="$HOME/.config/waybar/theme.css"
ROFI_THEMES_DIR="$HOME/.config/rofi/themes"
ROFI_THEME_FILE="$HOME/.config/rofi/theme.rasi"

if [[ ! -d "$WAYBAR_THEMES_DIR" ]]; then
  echo "Error: $WAYBAR_THEMES_DIR not found"
  exit 1
elif [[ ! -d "$ROFI_THEMES_DIR" ]]; then
  echo "Error: $ROFI_THEMES_DIR not found"
  exit 1
fi

# Get all themes
waybar_themes=("$WAYBAR_THEMES_DIR"/*.css)
waybar_theme_count=${#waybar_themes[@]}
rofi_themes=("$ROFI_THEMES_DIR"/*.rasi)
rofi_theme_count=${#rofi_themes[@]}

if [[ $waybar_theme_count -eq 0 ]]; then
  echo "Error: No themes found in $WAYBAR_THEMES_DIR"
  exit 1
elif [[ $rofi_theme_count -eq 0 ]]; then
  echo "Error: No themes found in $ROFI_THEMES_DIR"
  exit 1
fi

# Check which theme is currently applied
if [[ -L "$WAYBAR_THEME_FILE" ]]; then
  current_theme=$(readlink "$WAYBAR_THEME_FILE")
else
  current_theme=""
fi

next_theme_index=0

for i in "${!waybar_themes[@]}"; do
  if [[ "${waybar_themes[$i]}" == "$current_theme" ]]; then
    next_theme_index=$(((i + 1) % waybar_theme_count))
    break
  fi
done

new_waybar_theme="${waybar_themes[$next_theme_index]}"
new_rofi_theme="${rofi_themes[$next_theme_index]}"

# Apply new theme by creating a symlink instead of copying
ln -sf "$new_waybar_theme" "$WAYBAR_THEME_FILE"
ln -sf "$new_rofi_theme" "$ROFI_THEME_FILE"

# Restart Waybar to apply changes
killall waybar || true
nohup waybar >/dev/null 2>&1 &
