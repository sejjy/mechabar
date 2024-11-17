#!/usr/bin/env bash

# REQUIREMENTS:
# - Rofi: A window switcher/launcher (for UI).
# - bluetoothctl: A command-line tool for managing Bluetooth.
# - hyprctl & jq: For getting focused monitor resolution.

# Get monitor resolution and calculate center position
readarray -t monitor_res < <(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width,.height,.scale')

monitor_res[2]="${monitor_res[2]//./}"
monitor_res[0]=$((monitor_res[0] * 100 / monitor_res[2]))
monitor_res[1]=$((monitor_res[1] * 100 / monitor_res[2]))

x_center=$((monitor_res[0] / 2))
y_center=$((monitor_res[1] / 2))

# Rofi configuration
config="$HOME/.config/rofi/network-menu.rasi"
override="window { anchor: center; x-offset: -${x_center}px; y-offset: -${y_center}px; }"

# Initial notification
notify-send "Bluetooth" "Searching for available devices..."

while true; do
  # Check Bluetooth status
  bt_status=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

  if [[ "$bt_status" == "yes" ]]; then
    # Fetch available devices (names only)
    available_devices=$(bluetoothctl devices | awk '{$1=$2=""; print substr($0, 3)}')
    menu=" 󰂰  Rescan\n 󰂲  Disable Bluetooth\n$(echo "$available_devices" | awk '{print " 󰂱  " $0}')"
    rofi_theme="entry { placeholder: \"Search\"; } window { height: 250px; }"
  else
    menu=" 󰂯  Enable Bluetooth"
    rofi_theme="window { height: 48px; } mainbox { padding: 40px 0 -32px 0; } inputbar { enabled: false; }"
  fi

  # Display menu using Rofi
  selected_option=$(echo -e "$menu" | rofi -dmenu -i -selected-row 1 -theme-str "${override}" -config "${config}" -theme-str "${rofi_theme}")

  # Exit if no option is selected
  if [ -z "$selected_option" ]; then
    exit
  fi

  # Perform actions based on the selected option
  case "$selected_option" in
  " 󰂯  Enable Bluetooth")
    notify-send "Bluetooth" "Enabled"
    rfkill unblock bluetooth
    bluetoothctl power on
    sleep 1
    ;;
  " 󰂲  Disable Bluetooth")
    notify-send "Bluetooth" "Disabled"
    rfkill block bluetooth
    bluetoothctl power off
    sleep 1
    ;;
  " 󰂰  Rescan")
    notify-send "Bluetooth" "Rescanning for devices..."
    bluetoothctl scan on
    sleep 3
    bluetoothctl scan off
    notify-send "Bluetooth" "Device scan completed"
    ;;
  *)
    device_name=${selected_option// 󰂱  /}

    if [[ -n "$device_name" ]]; then
      device_mac=$(bluetoothctl devices | grep "$device_name" | awk '{print $2}')

      # Connect the device
      notify-send "Bluetooth" "Connecting to $device_name..."
      bluetoothctl connect "$device_mac" &
      sleep 3
      connection_status=$(bluetoothctl info "$device_mac" | grep "Connected:" | awk '{print $2}')

      if [[ "$connection_status" == "yes" ]]; then
        notify-send "Bluetooth" "Successfully connected to $device_name"
      else
        notify-send "Bluetooth" "Failed to connect to $device_name"
      fi
    fi
    ;;
  esac
done
