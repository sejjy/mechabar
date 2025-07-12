#!/usr/bin/env bash

# Rofi Bluetooth menu

# Author:  Jesse Mirabel
# GitHub:  https://github.com/sejjy
# License: MIT
#
# Created: July 12, 2025
# Updated: July 12, 2025

rofi_config="$HOME/.config/rofi/bluetooth-menu.rasi"

get_device_info() {
  local device_address="$1"
  local device_icon
  local device_name
  local device_type
  local line

  # extract device name and type
  while read -r line; do
    if [[ $line == Name:* ]]; then
      device_name="${line#Name: }"
    elif [[ $line == Icon:* ]]; then
      device_type="${line#Icon: }"
    fi

    if [[ -n $device_name && -n $device_type ]]; then
      break
    fi
  done <<< "$(bluetoothctl info "$device_address")"

  case "$device_type" in
    "audio-card")         device_icon="󱡫 " ;;
    "audio-headphones")   device_icon="󰋋 " ;;
    "audio-headset")      device_icon="󰋎 " ;;
    "camera-photo")       device_icon="󰄀 " ;;
    "camera-video")       device_icon="󰕧 " ;;
    "computer")           device_icon="󰍹 " ;;
    "input-gaming")       device_icon="󰊖 " ;;
    "input-keyboard")     device_icon="󰌌 " ;;
    "input-mouse")        device_icon="󰍽 " ;;
    "input-tablet")       device_icon="󰓷 " ;;
    "modem")              device_icon="󱂇 " ;;
    "multimedia-player")  device_icon="󰓃 " ;;
    "network-wireless")   device_icon="󰀂 " ;;
    "phone")              device_icon="󰄜 " ;;
    "printer")            device_icon="󰐪 " ;;
    "scanner")            device_icon="󰚫 " ;;
    "video-display")      device_icon="󰔂 " ;;
    *)                    device_icon="󰋖 " ;;
  esac

  echo "${device_icon} ${device_name} (${device_address})"
}

# main loop
while true; do
  is_bluetooth_powered=$(
    bluetoothctl show |
      while read -r line; do
        if [[ $line == Powered:* ]]; then
          echo "${line#Powered: }"
          break
        fi
      done
  )

  rofi_rows=()

  if [[ $is_bluetooth_powered == "yes" ]]; then
    rofi_rows+=("󰂲  Disable Bluetooth")
    rofi_rows+=("󰏌  Scan for devices")

    while read -r line; do
      if [[ $line == Device* ]]; then
        # extract only the address
        device_address="${line#Device }"
        device_address="${device_address%% *}"

        device_info=$(get_device_info "$device_address")
        rofi_rows+=("${device_info}")
      else
        continue
      fi
    done <<< "$(bluetoothctl devices)"

    rofi_config_override=()

  else
    # bluetooth is disabled
    rofi_rows=("󰂯  Enable Bluetooth")
    rofi_config_override=(
      -theme-str \
        "mainbox { children: [ textbox-custom, listview ]; } \
        listview { lines: 1; padding: 6px 6px 8px; }"
    )
  fi

  rofi_prompt=" "

  rofi_selected_row=$(
    printf "%s\n" "${rofi_rows[@]}" |
      rofi -dmenu -selected-row 0 -p "$rofi_prompt" \
      -config "$rofi_config" "${rofi_config_override[@]}"
  )

  if [[ -z $rofi_selected_row ]]; then
    exit
  fi

  case $rofi_selected_row in
    *"Enable Bluetooth")
      notify-send "Bluetooth enabled" \
        --icon="package-installed-outdated"
      rfkill unblock bluetooth
      bluetoothctl power on
      sleep 1
      ;;
    *"Disable Bluetooth")
      notify-send "Bluetooth disabled" \
        --icon="package-broken"
      rfkill block bluetooth
      bluetoothctl power off
      exit
      ;;
    *"Scan for devices")
      notify-send "Press '?' to show help" \
        --icon="package-installed-outdated"
      kitty --title "󰂱  Bluetooth TUI" bash -c "bluetui"
      ;;
    *)
      device_name="${rofi_selected_row%% (*}"
      device_name="${device_name:3}" # removes the icon and leading spaces

      device_address="${rofi_selected_row##*(}"
      device_address="${device_address%)}"

      if [[ -n $device_address ]]; then
        notify-send "Connecting to $device_name" \
          --icon="package-installed-outdated"

        bluetoothctl trust "$device_address" &&
        bluetoothctl pair "$device_address" &&
        bluetoothctl connect "$device_address"
        sleep 3

        is_device_connected=""

        while read -r line; do
          if [[ $line == Connected:* ]]; then
            is_device_connected="${line#Connected: }"
            break
          fi
        done <<< "$(bluetoothctl info "$device_address")"

        if [[ $is_device_connected == "yes" ]]; then
          notify-send "Connected to $device_name" \
            --icon="package-install"
          exit
        else
          notify-send "Failed to connect to $device_name" \
            --icon="package-broken"
        fi

      else
        notify-send "Device not found" \
          --icon="package-broken"
      fi
      ;;
  esac
done
