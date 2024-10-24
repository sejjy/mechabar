#!/usr/bin/env bash

# This script allows you to:
# - Enable or disable Wi-Fi.
# - Select and connect to a Wi-Fi network.
# - Manually input SSID and password for Wi-Fi.
#
# It integrates with Rofi for a user-friendly menu interface
# and nmcli to handle network management.
#
# REQUIREMENTS:
# - Rofi: A window switcher/launcher (for UI).
# - nmcli: A command-line tool for managing NetworkManager.
# - hyprctl & jq: For getting focused monitor resolution.
#
# WARNING:
# The script assumes that certain variables (such as
# font size, border size, and screen resolution) are valid.
# If these values are missing or invalid, the script may not
# behave as expected. If you plan to use this in multiple
# environments, consider adding more input validation.

# Rofi configuration file path
config="$HOME/.config/rofi/wifi.rasi"

# Default border and font size
border_width=2
scale=10
font="configuration { font: \"JetBrainsMono Nerd Font ${scale}\"; }"

# Get monitor resolution and calculate center position
# This determines where the Rofi window will appear (centered on screen).
readarray -t monitor_res < <(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width,.height,.scale')
monitor_res[2]="${monitor_res[2]//./}"
monitor_res[0]=$((monitor_res[0] * 100 / monitor_res[2]))
monitor_res[1]=$((monitor_res[1] * 100 / monitor_res[2]))

x_center=$((monitor_res[0] / 2))
y_center=$((monitor_res[1] / 2))

# Rofi interface
override="window { anchor: center; x-offset: -${x_center}px; y-offset: -${y_center}px; 
border: ${border_width}px; border-radius: 15px; } \
wallbox { border-radius: 10px; } element { border-radius: 10px; }"

# Init notification
notify-send "Searching for available Wi-Fi networks..."

# Get list of available Wi-Fi networks and format it
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' |
    sed -E "s/WPA*.?\S/  /g" | sed "s/^--/  /g" | sed "s/    / /g" | sed "/--/d")

# Check current Wi-Fi status (enabled/disabled)
status=$(nmcli -fields WIFI g)
if [[ "$status" =~ "enabled" ]]; then
    toggle=" 󰤭  Disable Wi-Fi"
elif [[ "$status" =~ "disabled" ]]; then
    toggle=" 󰤨  Enable Wi-Fi"
fi

# Display Wi-Fi menu
selected=$(echo -e "   Manual Entry\n$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 \
    -theme-str "entry { placeholder: \"Search...\"; }" -theme-str "${font}" -theme-str "${override}" \
    -config "${config}")

# Extract chosen SSID
ssid="${selected:3}"

# User selection
if [ -z "$selected" ]; then
    # Exit if nothing is selected
    exit
elif [ "$selected" = " 󰤨  Enable Wi-Fi" ]; then
    # Enable Wi-Fi if selected
    nmcli radio wifi on
elif [ "$selected" = " 󰤭  Disable Wi-Fi" ]; then
    # Disable Wi-Fi if selected
    nmcli radio wifi off
elif [ "$selected" = "   Manual Entry" ]; then
    # Manual entry
    manual_ssid=$(rofi -dmenu -theme-str "entry { placeholder: \"Enter SSID...\"; }" -theme-str "${font}" \
        -theme-str "${override}" -config "${config}")

    # Exit if no SSID is provided
    [ -z "$manual_ssid" ] && exit

    # Prompt for the Wi-Fi password (optional)
    manual_password=$(rofi -dmenu -theme-str "entry { placeholder: \"Enter Password...\"; }" -theme-str "${font}" \
        -theme-str "${override}" -config "${config}")

    # Connect to Wi-Fi with or without a password
    if [ -z "$manual_password" ]; then
        nmcli device wifi connect "$manual_ssid"
    else
        nmcli device wifi connect "$manual_ssid" password "$manual_password"
    fi
else
    # Connected notification
    notify="You are now connected to \"$ssid\"."

    # Check if the selected network is saved
    saved_network=$(nmcli -g NAME connection)
    if [[ $(echo "$saved_network" | grep -w "$ssid") == "$ssid" ]]; then
        # Connect to saved network
        nmcli connection up id "$ssid" | grep "successfully" && notify-send "Connection Established" "$notify"
    else
        # Prompt for password if the network is secure
        if [[ "$selected" =~ " " ]]; then
            wifi_password=$(rofi -dmenu -theme-str "entry { placeholder: \"Password: \"; }" -theme-str "${font}" \
                -theme-str "${override}" -config "${config}")
        fi
        # Connect to the selected Wi-Fi network
        nmcli device wifi connect "$ssid" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$notify"
    fi
fi
