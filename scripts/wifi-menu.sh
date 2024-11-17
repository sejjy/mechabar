#!/usr/bin/env bash

# This script allows you to:
# - Enable or disable Wi-Fi.
# - Select and connect to a Wi-Fi network.
# - Manually input SSID and password for Wi-Fi.
#
# REQUIREMENTS:
# - Rofi: A window switcher/launcher (for UI).
# - nmcli: A command-line tool for managing NetworkManager.
# - hyprctl & jq: For getting focused monitor resolution.

# Get monitor resolution and calculate center position
# This determines where the Rofi window will appear.
readarray -t monitor_res < <(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width,.height,.scale')

monitor_res[2]="${monitor_res[2]//./}"
monitor_res[0]=$((monitor_res[0] * 100 / monitor_res[2]))
monitor_res[1]=$((monitor_res[1] * 100 / monitor_res[2]))

x_center=$((monitor_res[0] / 2))
y_center=$((monitor_res[1] / 2))

# Rofi configuration
config="$HOME/.config/rofi/network-menu.rasi"
override="window { anchor: center; x-offset: -${x_center}px; y-offset: -${y_center}px; }"

# Init notification
notify-send "Wi-Fi" "Searching for available networks..."

while true; do

  # Get list of available Wi-Fi networks and apply formatting
  wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/  /g" | sed "s/^--/  /g" | sed "s/    / /g" | sed "/--/d")

  # Check current Wi-Fi status (enabled/disabled) and
  # Display the menu based on status
  wifi_status=$(nmcli -fields WIFI g)

  if [[ "$wifi_status" =~ "enabled" ]]; then
    selected_option=$(echo -e "   Rescan\n   Manual Entry\n 󰤭  Disable Wi-Fi\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 2 -theme-str "entry { placeholder: \"Search\"; }" -theme-str "${override}" -config "${config}" -theme-str "window { height: 250px; }")

  elif [[ "$wifi_status" =~ "disabled" ]]; then
    selected_option=$(echo -e " 󰤨  Enable Wi-Fi" | uniq -u | rofi -dmenu -i -theme-str "${override}" -config "${config}" -theme-str "window { height: 48px; } mainbox { padding: 40px 0 -32px 0;} inputbar { enabled: false; }")
  fi

  # Extract selected SSID
  read -r selected_ssid <<<"${selected_option:4}"

  # Perform actions based on the selected option
  if [ "$selected_option" = "" ]; then
    exit

  elif [ "$selected_option" = " 󰤨  Enable Wi-Fi" ]; then
    notify-send "Wi-Fi" "Enabled"
    notify-send "Wi-Fi" "Rescanning for networks..."
    nmcli radio wifi on
    nmcli device wifi rescan
    sleep 3

  elif [ "$selected_option" = " 󰤭  Disable Wi-Fi" ]; then
    notify-send "Wi-Fi" "Disabled"
    nmcli radio wifi off
    sleep 1

  elif [ "$selected_option" = "   Manual Entry" ]; then
    notify-send "Wi-Fi" "Enter SSID and password manually..."

    # Prompt for manual SSID and password
    manual_ssid=$(rofi -dmenu -theme-str "entry { placeholder: \"Enter SSID\"; }" -theme-str "${override}" -config "${config}" -theme-str "window { height: 48px; } mainbox { padding: 8px 0; }")

    if [ -z "$manual_ssid" ]; then
      exit
    fi

    manual_password=$(rofi -dmenu -password -theme-str "entry { placeholder: \"Enter password\"; }" -theme-str "${override}" -config "${config}" -theme-str "window { height: 48px; } mainbox { padding: 8px 0; }")

    if [ -z "$manual_password" ]; then
      nmcli device wifi connect "$manual_ssid"
    else
      nmcli device wifi connect "$manual_ssid" password "$manual_password"
    fi

  elif [ "$selected_option" = "   Rescan" ]; then
    # Trigger Wi-Fi rescan
    notify-send "Wi-Fi" "Rescanning for networks..."
    nmcli device wifi rescan
    sleep 3
    notify-send "Wi-Fi" "Network scan completed"
  else
    # Notify when connection is activated successfully
    connected_notif="Connected to \"$selected_ssid\"."

    # Get saved connections
    saved_connections=$(nmcli -g NAME connection)

    if [[ $(echo "$saved_connections" | grep -w "$selected_ssid") = "$selected_ssid" ]]; then
      nmcli connection up id "$selected_ssid" | grep "successfully" && notify-send "Connection Established" "$connected_notif"

    else
      if [[ "$selected_option" =~ " " ]]; then
        wifi_password=$(rofi -dmenu -password -theme-str "entry { placeholder: \"Enter password: \"; }" -theme-str "${override}" -config "${config}" -theme-str "window { height: 48px; } mainbox { padding: 8px 0; }")
      fi

      nmcli device wifi connect "$selected_ssid" password "$wifi_password" | grep "successfully" && notify-send "Wi-Fi" "$connected_notif"
    fi
  fi

done
