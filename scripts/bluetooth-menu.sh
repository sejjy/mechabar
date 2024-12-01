#!/usr/bin/env bash

# This script allows you to:
# - Enable or disable Bluetooth.
# - Scan for available devices.
# - Connect to a device.

# Rofi configuration
config="$HOME/.config/rofi/wifi-bluetooth-menu.rasi"

# Initial notification
notify-send "Bluetooth" "Searching for available devices..."

while true; do
  # Check Bluetooth status
  bluetooth_status=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

  if [[ "$bluetooth_status" == "yes" ]]; then
    # Fetch available devices (names only)
    bluetooth_devices=$(bluetoothctl devices | awk '{$1=$2=""; print substr($0, 3)}')
    options=" 󰂰  Rescan\n 󰂲  Disable Bluetooth\n$(echo "$bluetooth_devices" | awk '{print " 󰂱  " $0}')"
    override="entry { placeholder: \"Search\"; } window { height: 178px; } listview { lines: 6; }"
  else
    options=" 󰂯  Enable Bluetooth"
    override="window { height: 43px; } wallbox { children: false; }"
  fi

  # Display menu using Rofi
  selected_option=$(echo -e "$options" | rofi -dmenu -i -selected-row 1 -config "${config}" -theme-str "${override}")

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
    # Extract the device name and remove the icon prefix
    device_name=${selected_option// 󰂱  /}

    if [[ -n "$device_name" ]]; then
      # Find the device's MAC address
      device_mac=$(bluetoothctl devices | grep "$device_name" | awk '{print $2}')

      # Connect the device
      notify-send "Bluetooth" "Connecting to $device_name..."
      bluetoothctl connect "$device_mac" &
      sleep 3

      # Check connection status
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
