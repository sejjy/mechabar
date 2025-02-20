#!/usr/bin/env bash

WAYBAR_CSS_DIR="$HOME/.config/waybar/themes/css"
WAYBAR_CSS_FILE="$HOME/.config/waybar/theme.css"
WAYBAR_JSONC_DIR="$HOME/.config/waybar/themes/jsonc"
WAYBAR_JSONC_FILE="$HOME/.config/waybar/config.jsonc"
ROFI_THEMES_DIR="$HOME/.config/rofi/themes"
ROFI_THEME_FILE="$HOME/.config/rofi/theme.rasi"
CURRENT_THEME_FILE="$HOME/.config/waybar/themes/current-theme"

if [[ ! -d "$WAYBAR_CSS_DIR" ]]; then
  echo "Error: $WAYBAR_CSS_DIR not found"
  exit 1
elif [[ ! -d "$WAYBAR_JSONC_DIR" ]]; then
  echo "Error: $WAYBAR_JSONC_DIR not found"
  exit 1
elif [[ ! -d "$ROFI_THEMES_DIR" ]]; then
  echo "Error: $ROFI_THEMES_DIR not found"
  exit 1
fi

# Get all themes
WAYBAR_CSS=("$WAYBAR_CSS_DIR"/*.css)
WAYBAR_CSS_COUNT=${#WAYBAR_CSS[@]}
WAYBAR_JSONC=("$WAYBAR_JSONC_DIR"/*.jsonc)
WAYBAR_JSONC_COUNT=${#WAYBAR_JSONC[@]}
ROFI_THEMES=("$ROFI_THEMES_DIR"/*.rasi)
ROFI_THEME_COUNT=${#ROFI_THEMES[@]}

if [[ $WAYBAR_CSS_COUNT -eq 0 ]]; then
  echo "Error: No themes found in $WAYBAR_CSS_DIR"
  exit 1
elif [[ $WAYBAR_JSONC_COUNT -eq 0 ]]; then
  echo "Error: No themes found in $WAYBAR_JSONC_DIR"
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

for i in "${!WAYBAR_CSS[@]}"; do
  if [[ "${WAYBAR_CSS[$i]}" == "$CURRENT_THEME" ]]; then
    NEXT_THEME_INDEX=$(((i + 1) % WAYBAR_CSS_COUNT))
    break
  fi
done

for i in "${!WAYBAR_JSONC[@]}"; do
  if [[ "${WAYBAR_JSONC[$i]}" == "$CURRENT_THEME" ]]; then
    NEXT_THEME_INDEX=$(((i + 1) % WAYBAR_JSONC_COUNT))
    break
  fi
done

for i in "${!ROFI_THEMES[@]}"; do
  if [[ "${ROFI_THEMES[$i]}" == "$CURRENT_THEME" ]]; then
    NEXT_THEME_INDEX=$(((i + 1) % ROFI_THEME_COUNT))
    break
  fi
done

NEW_WAYBAR_CSS="${WAYBAR_CSS[$NEXT_THEME_INDEX]}"
NEW_WAYBAR_JSONC="${WAYBAR_JSONC[$NEXT_THEME_INDEX]}"
NEW_ROFI_THEME="${ROFI_THEMES[$NEXT_THEME_INDEX]}"

# Save the new theme
echo "$NEW_WAYBAR_CSS" >"$CURRENT_THEME_FILE"

# Apply new theme
cp "$NEW_WAYBAR_CSS" "$WAYBAR_CSS_FILE"
cp "$NEW_WAYBAR_JSONC" "$WAYBAR_JSONC_FILE"
cp "$NEW_ROFI_THEME" "$ROFI_THEME_FILE"

# Restart Waybar to apply changes
killall waybar || true
nohup waybar >/dev/null 2>&1 &
