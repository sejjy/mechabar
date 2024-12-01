#!/usr/bin/env bash

# Rofi configuration
config="$HOME/.config/rofi/wifi-bluetooth-menu.rasi"

# Init notification
notify-send "Wi-Fi" "Searching for available networks..."

while true; do
  # Get list of available Wi-Fi networks and apply formatting
  wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list |
    sed 1d |
    sed 's/  */ /g' |
    sed -E "s/WPA*.?\S/  /g" |
    sed "s/^--/  /g" |
    sed "s/    / /g" |
    sed "/--/d")

  # Check current Wi-Fi status (enabled/disabled)
  wifi_status=$(nmcli -fields WIFI g)

  # Display the menu based on Wi-Fi status
  if [[ "$wifi_status" =~ "enabled" ]]; then
    selected_option=$(echo -e "   Rescan\n   Manual Entry\n 󰤭  Disable Wi-Fi\n$wifi_list" |
      rofi -dmenu -i -selected-row 2 -config "${config}" -theme-str "window { height: 205px; }")
  elif [[ "$wifi_status" =~ "disabled" ]]; then
    selected_option=$(echo -e " 󰤨  Enable Wi-Fi" |
      rofi -dmenu -i -config "${config}" -theme-str "window { height: 43px; } wallbox { children: false; }")
  fi

  # Extract selected SSID
  read -r selected_ssid <<<"${selected_option:4}"

  # Perform actions based on the selected option
  if [ -z "$selected_option" ]; then
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

    # Prompt for manual SSID
    manual_ssid=$(rofi -dmenu \
      -config "${config}" \
      -theme-str "window { height: 43px; } wallbox { enabled: true; } entry { placeholder: \"Enter SSID\"; }")

    if [ -z "$manual_ssid" ]; then
      exit
    fi

    # Prompt for password using reusable function
    get_password() {
      rofi -dmenu -password \
        -config "${config}" \
        -theme-str "window { height: 43px; } wallbox { enabled: true; } entry { placeholder: \"Enter password\"; }"
    }

    manual_password=$(get_password)

    if [ -z "$manual_password" ]; then
      nmcli device wifi connect "$manual_ssid"
    else
      nmcli device wifi connect "$manual_ssid" password "$manual_password"
    fi

  elif [ "$selected_option" = "   Rescan" ]; then
    notify-send "Wi-Fi" "Rescanning for networks..."
    nmcli device wifi rescan
    sleep 3
    notify-send "Wi-Fi" "Network scan completed"

  else
    # Notify when connection is activated successfully
    connected_notif="Connected to \"$selected_ssid\"."

    # Get saved connections
    saved_connections=$(nmcli -g NAME connection)

    if echo "$saved_connections" | grep -qw "$selected_ssid"; then
      nmcli connection up id "$selected_ssid" |
        grep "successfully" &&
        notify-send "Connection Established" "$connected_notif"
    else
      # Handle secure network connection
      if [[ "$selected_option" =~ " " ]]; then
        wifi_password=$(get_password)
      fi

      nmcli device wifi connect "$selected_ssid" password "$wifi_password" |
        grep "successfully" &&
        notify-send "Wi-Fi" "$connected_notif"
    fi
  fi
done
