#!/usr/bin/env bash

# Author: Jesse Mirabel (@sejjy)
# GitHub: https://github.com/sejjy/mechabar

# Rofi config
config="$HOME/.config/rofi/wifi-bluetooth-menu.rasi"

# Rofi window override
override_disabled="inputbar { enabled: false; } listview { lines: 1; padding: 6px; }"

while true; do
  # Fetch available devices (names only)
  bluetooth_devices=$(bluetoothctl devices | awk '{$1=$2=""; print substr($0, 3)}')

  options=$(
    echo "Scan for devices  "
    echo "Disable Bluetooth"
    echo "$bluetooth_devices" | awk '{print "󰂱  " $0}'
  )
  option="Enable Bluetooth"

  # (enabled/disabled)
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
    kitty --title '󰂯  Bluetooth TUI' bash -c "bluetui"
    ;;
  *)
    # Extract device name
    device_name=${selected_option//󰂱  /}

    if [[ -n "$device_name" ]]; then
      # Find the device's MAC address
      device_mac=$(bluetoothctl devices | grep "$device_name" | awk '{print $2}')

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
