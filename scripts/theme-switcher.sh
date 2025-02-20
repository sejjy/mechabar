#!/usr/bin/env bash

WAYBAR_CSS_DIR="$HOME/.config/waybar/themes/css"
WAYBAR_CSS_FILE="$HOME/.config/waybar/theme.css"
WAYBAR_JSONC_DIR="$HOME/.config/waybar/themes/jsonc"
WAYBAR_JSONC_FILE="$HOME/.config/waybar/config.jsonc"
ROFI_THEMES_DIR="$HOME/.config/rofi/themes"
ROFI_THEME_FILE="$HOME/.config/rofi/theme.rasi"
CURRENT_THEME_FILE="$HOME/.config/waybar/themes/current-theme"

for dir in "$WAYBAR_CSS_DIR" "$WAYBAR_JSONC_DIR" "$ROFI_THEMES_DIR"; do
  [[ ! -d "$dir" ]] && echo "Error: $dir not found" && exit 1
done

# Get all themes
waybar_css=("$WAYBAR_CSS_DIR"/*.css)
waybar_jsonc=("$WAYBAR_JSONC_DIR"/*.jsonc)
rofi_themes=("$ROFI_THEMES_DIR"/*.rasi)

if [[ ${#waybar_css[@]} -eq 0 || ${#waybar_jsonc[@]} -eq 0 || ${#rofi_themes[@]} -eq 0 ]]; then
  echo "Error: No themes found in one of the directories"
  exit 1
fi

# Get the current theme
current_theme=$(cat "$CURRENT_THEME_FILE" 2>/dev/null || echo "")

# Find the index of the current theme
next_theme_index=0
for i in "${!waybar_css[@]}"; do
  [[ "${waybar_css[$i]}" == "$current_theme" ]] && next_theme_index=$(((i + 1) % ${#waybar_css[@]})) && break
done

# Get the new theme
new_waybar_css="${waybar_css[$next_theme_index]}"
new_waybar_jsonc="${waybar_jsonc[$next_theme_index]}"
new_rofi_theme="${rofi_themes[$next_theme_index]}"

# Save the new theme
echo "$new_waybar_css" >"$CURRENT_THEME_FILE"

declare -A theme_files=(
  ["$new_waybar_css"]="$WAYBAR_CSS_FILE"
  ["$new_waybar_jsonc"]="$WAYBAR_JSONC_FILE"
  ["$new_rofi_theme"]="$ROFI_THEME_FILE"
)

for src in "${!theme_files[@]}"; do
  cp "$src" "${theme_files[$src]}"
done

# Restart Waybar to apply changes
killall waybar || true
nohup waybar --config "$HOME/.config/waybar/config.jsonc" --style "$HOME/.config/waybar/style.css" >/dev/null 2>&1 &
