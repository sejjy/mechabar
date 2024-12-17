#!/usr/bin/env bash

# Author: Jesse Mirabel (@sejjy)
# GitHub: https://github.com/sejjy/mechabar

# Rofi config
config="$HOME/.config/rofi/bluetooth-menu.rasi"

# Rofi window override
override_disabled="inputbar { enabled: false; } listview { lines: 1; padding: 6px; }"

# Function to determine device type and return appropriate icon
get_device_icon() {
  local device_mac=$1

  # Get the Class and appearance of the device
  device_info=$(bluetoothctl info "$device_mac")
  appearance=$(echo "$device_info" | grep "Icon:" | awk '{print $2}')

  # Assign icons based on class or appearance
  case "$appearance" in
  "audio-headphones" | "audio-headset") echo "󰋋 " ;; # Headphones
  "video-display" | "computer") echo "󰍹 " ;;         # Monitor
  "audio-input-microphone") echo "󰍬 " ;;             # Microphone
  "audio-speakers") echo "󰓃 " ;;                     # Speakers
  "input-keyboard") echo "󰌌 " ;;                     # Keyboard
  "input-mouse") echo "󰍽 " ;;                        # Mouse
  "phone") echo "󰏲 " ;;                              # Phone
  *)
    echo "󰂱 " # Default
    ;;
  esac
}

while true; do
  # Fetch available devices (names and icons)
  bluetooth_devices=$(bluetoothctl devices | while read -r line; do
    device_mac=$(echo "$line" | awk '{print $2}')
    device_name=$(echo "$line" | awk '{$1=$2=""; print substr($0, 3)}')
    icon=$(get_device_icon "$device_mac")
    echo "$icon $device_name"
  done)

  options=$(
    echo "Scan for devices  "
    echo "Disable Bluetooth"
    echo "$bluetooth_devices"
  )
  option="Enable Bluetooth"

  # Get Bluetooth status (enabled/disabled)
  bluetooth_status=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

  if [[ "$bluetooth_status" == "yes" ]]; then
    selected_option=$(echo -e "$options" | rofi -dmenu -i -selected-row 1 -config "${config}" -p " ")
  else
    selected_option=$(echo -e "$option" | rofi -dmenu -i -selected-row 1 -config "${config}" -theme-str "${override_disabled}" -p " ")
  fi

  # Exit if no option is selected
  if [ -z "$selected_option" ]; then
    exit
  fi

  # Actions based on selected option
  case "$selected_option" in
  "Enable Bluetooth")
    notify-send "Bluetooth Enabled"
    rfkill unblock bluetooth
    bluetoothctl power on
    sleep 1
    ;;
  "Disable Bluetooth")
    notify-send "Bluetooth Disabled"
    rfkill block bluetooth
    bluetoothctl power off
    sleep 1
    ;;
  "Scan for devices"*)
    notify-send "Press '?' to show help."
    kitty --title '󰂱  Bluetooth TUI' bash -c "bluetui"
    ;;
  *)
    # Extract device name
    device_name="${selected_option#* }"
    device_name="${device_name## }"

    if [[ -n "$device_name" ]]; then
      # Find the device's MAC address
      device_mac=$(bluetoothctl devices | grep "$device_name" | awk '{print $2}')

      # Trust and pair the device
      bluetoothctl trust "$device_mac" >/dev/null 2>&1
      bluetoothctl pair "$device_mac" >/dev/null 2>&1

      # Connect the device
      bluetoothctl connect "$device_mac" &
      sleep 3

      # Check connection status
      connection_status=$(bluetoothctl info "$device_mac" | grep "Connected:" | awk '{print $2}')

      if [[ "$connection_status" == "yes" ]]; then
        notify-send "Connected to \"$device_name\"."
      else
        notify-send "Failed to connect to \"$device_name\"."
      fi
    fi
    ;;
  esac
done
