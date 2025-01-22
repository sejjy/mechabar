#!/usr/bin/env bash

# Author: Jesse Mirabel (@sejjy)
# GitHub: https://github.com/sejjy/mechabar

# Rofi config
config="$HOME/.config/rofi/wifi-menu.rasi"

options=$(
  echo "Manual Entry"
  echo "Disable Wi-Fi"
)
option_disabled="Enable Wi-Fi"

# Rofi window override
override_ssid="entry { placeholder: \"Enter SSID\"; } listview { enabled: false; }"
override_password="entry { placeholder: \"Enter password\"; } listview { enabled: false; }"
override_disabled="mainbox { children: [ listview ]; } listview { lines: 1; padding: 6px; }"

# Prompt for password
get_password() {
  rofi -dmenu -password -config "${config}" -theme-str "${override_password}" -p " " || pkill -x rofi
}

while true; do
  wifi_list() {
    nmcli --fields "SECURITY,SSID" device wifi list |
      tail -n +2 |               # Skip the header line from nmcli output
      sed 's/  */ /g' |          # Replace multiple spaces with a single space
      sed -E "s/WPA*.?\S/󰤪 /g" | # Replace 'WPA*' with a Wi-Fi lock icon
      sed "s/^--/󰤨 /g" |         # Replace '--' (open networks) with an open Wi-Fi icon
      sed "s/󰤪  󰤪/󰤪/g" |         # Remove duplicate Wi-Fi lock icons
      sed "/--/d" |              # Remove lines containing '--' (empty SSIDs)
      awk '!seen[$0]++'          # Filter out duplicate SSIDs
  }

  # Get Wi-Fi status
  wifi_status=$(nmcli -fields WIFI g)

  case "$wifi_status" in
  *"enabled"*)
    selected_option=$(echo "$options"$'\n'"$(wifi_list)" |
      rofi -dmenu -i -selected-row 1 -config "${config}" -p " " || pkill -x rofi)
    ;;
  *"disabled"*)
    selected_option=$(echo "$option_disabled" |
      rofi -dmenu -i -config "${config}" -theme-str "${override_disabled}" || pkill -x rofi)
    ;;
  esac

  # Extract selected SSID
  read -r selected_ssid <<<"${selected_option:3}"

  # Actions based on selected option
  case "$selected_option" in
  "")
    exit
    ;;
  "Enable Wi-Fi")
    notify-send "Scanning for networks..."
    nmcli radio wifi on
    nmcli device wifi rescan
    sleep 3
    ;;
  "Disable Wi-Fi")
    notify-send "Wi-Fi Disabled"
    nmcli radio wifi off
    exit
    ;;
  "Manual Entry")
    # Prompt for SSID
    manual_ssid=$(rofi -dmenu -config "${config}" -theme-str "${override_ssid}" -p " " || pkill -x rofi)

    # Exit if no option is selected
    if [ -z "$manual_ssid" ]; then
      exit
    fi

    # Prompt for Wi-Fi password
    wifi_password=$(get_password)

    if [ -z "$wifi_password" ]; then
      # Without password
      if nmcli device wifi connect "$manual_ssid" | grep -q "successfully"; then
        notify-send "Connected to \"$manual_ssid\"."
        exit
      else
        notify-send "Failed to connect to \"$manual_ssid\"."
      fi
    else
      # With password
      if nmcli device wifi connect "$manual_ssid" password "$wifi_password" | grep -q "successfully"; then
        notify-send "Connected to \"$manual_ssid\"."
        exit
      else
        notify-send "Failed to connect to \"$manual_ssid\"."
      fi
    fi
    ;;
  *)
    # Get saved connections
    saved_connections=$(nmcli -g NAME connection)

    if echo "$saved_connections" | grep -qw "$selected_ssid"; then
      if nmcli connection up id "$selected_ssid" | grep -q "successfully"; then
        notify-send "Connected to \"$selected_ssid\"."
        exit
      else
        notify-send "Failed to connect to \"$selected_ssid\"."
      fi
    else
      # Handle secure network connection
      if [[ "$selected_option" =~ ^"󰤪" ]]; then
        wifi_password=$(get_password)
      fi

      if nmcli device wifi connect "$selected_ssid" password "$wifi_password" | grep -q "successfully"; then
        notify-send "Connected to \"$selected_ssid\"."
        exit
      else
        notify-send "Failed to connect to \"$selected_ssid\"."
      fi
    fi
    ;;
  esac
done
