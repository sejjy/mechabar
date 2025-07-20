#!/usr/bin/env bash

# Rofi Audio menu for PipeWire/PulseAudio

# Check for dependencies
if ! command -v pactl &> /dev/null; then
    notify-send "Error" "pactl not found. Please install pipewire-pulse or pulseaudio-utils." -i "dialog-error"
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

# Get device list with current device marked with *
get_devices() {
  local type=$1
  local current=$2
  pactl list "$type" | awk -v current="$current" '
    /Name: / {name=$2}
    /Description: / {
      desc=$0; 
      sub(/.*Description: /, "", desc);
      if (name == current) {
        print "* " desc " (" name ")"
      } else {
        print "  " desc " (" name ")"
      }
    }
  '
}

# Create menu options with headers and current device indicators
rofi_options=()
rofi_options+=("󰓃 OUTPUT DEVICES")
while IFS= read -r line; do
  rofi_options+=("$line")
done <<< "$(get_devices sinks "$current_sink")"

rofi_options+=("")
rofi_options+=("󰍬 INPUT DEVICES")
while IFS= read -r line; do
  rofi_options+=("$line")
done <<< "$(get_devices sources "$current_source")"

# Launch rofi
rofi_selected=$(printf "%s\n" "${rofi_options[@]}" | rofi -dmenu -p "Audio" -config "$ROFI_CONFIG")

# If nothing is selected, exit
if [[ -z "$rofi_selected" ]] || [[ "$rofi_selected" == "󰓃 OUTPUT DEVICES" ]] || [[ "$rofi_selected" == "󰍬 INPUT DEVICES" ]] || [[ "$rofi_selected" == "" ]]; then
  exit 0
fi

# Extract device name from selection
device_name=$(echo "$rofi_selected" | awk -F'[()]' '{print $2}')

# Determine if this is a sink or source and set as default
if pactl list short sinks | grep -q "$device_name"; then
  pactl set-default-sink "$device_name"
  notify-send "Audio Output Changed" "Set default to: $(echo "$rofi_selected" | sed 's/^[ *]*//' | sed 's/ ([^)]*)//')" -i "audio-speakers"
elif pactl list short sources | grep -q "$device_name"; then
  pactl set-default-source "$device_name"
  notify-send "Audio Input Changed" "Set default to: $(echo "$rofi_selected" | sed 's/^[ *]*//' | sed 's/ ([^)]*)//')" -i "audio-input-microphone"
fi
