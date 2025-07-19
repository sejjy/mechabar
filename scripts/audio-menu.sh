#!/usr/bin/env bash

# Rofi Audio menu

# Check for dependencies
if ! command -v pactl &> /dev/null; then
    notify-send "Error" "pactl not found. Please install pulseaudio-utils." -i "dialog-error"
    exit 1
fi

if ! command -v notify-send &> /dev/null; then
    echo "notify-send not found, please install libnotify"
    exit 1
fi

ROFI_CONFIG="$HOME/.config/rofi/audio-menu.rasi"

# Get the current default sink and source
current_sink=$(pactl get-default-sink)
current_source=$(pactl get-default-source)

# Function to get device list
get_devices() {
  local type=$1
  pactl list short "$type" | while read -r line; do
    local device_name=$(echo "$line" | awk '{print $2}')
    local description=$(pactl list "$type" | grep -A 5 "Name: $device_name" | grep "Description:" | cut -d ' ' -f 2-)
    echo "$description ($device_name)"
  done
}

# Rofi menu options
rofi_options=()
rofi_options+=("󰓃 Sinks")
while IFS= read -r line; do
  rofi_options+=("  $line")
done <<< "$(get_devices sinks)"

rofi_options+=("󰍬 Sources")
while IFS= read -r line; do
  rofi_options+=("  $line")
done <<< "$(get_devices sources)"

# Launch rofi
rofi_selected=$(printf "%s\n" "${rofi_options[@]}" | rofi -dmenu -p "Audio" -config "$ROFI_CONFIG")

# If nothing is selected, exit
if [[ -z "$rofi_selected" ]]; then
  exit 0
fi

# Extract device name from selection
device_name=$(echo "$rofi_selected" | awk -F'[()]' '{print $2}')

# Set the default device
if [[ "$rofi_selected" == *"Sink"* ]] || [[ "$rofi_selected" == *"  "* ]]; then
  if pactl list short sinks | grep -q "$device_name"; then
    pactl set-default-sink "$device_name"
    notify-send "Audio Output Changed" "Set to $device_name" -i "audio-speakers"
  elif pactl list short sources | grep -q "$device_name"; then
    pactl set-default-source "$device_name"
    notify-send "Audio Input Changed" "Set to $device_name" -i "audio-input-microphone"
  fi
fi
