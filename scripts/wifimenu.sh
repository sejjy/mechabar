#!/bin/bash

hypr_border=1
roconf="$HOME/.config/rofi/wifi.rasi"

# Set rofi scaling
[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration { font: \"JetBrainsMono Nerd Font ${rofiScale}\"; }"
wind_border=$((hypr_border * 3 / 2))
elem_border=$([ "$hypr_border" -eq 0 ] && echo "5" || echo "$hypr_border")

# Ensure that hypr_width, wind_border, and elem_border have valid numeric values
[[ "${hypr_width}" =~ ^[0-9]+$ ]] || hypr_width=2
[[ "${wind_border}" =~ ^[0-9]+$ ]] || wind_border=0
[[ "${elem_border}" =~ ^[0-9]+$ ]] || elem_border=0

# Get monitor resolution and calculate center position
readarray -t monRes < <(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width,.height,.scale')
monRes[2]="${monRes[2]//./}"
monRes[0]=$((monRes[0] * 100 / monRes[2]))
monRes[1]=$((monRes[1] * 100 / monRes[2]))

x_pos_center=$((monRes[0] / 2))
y_pos_center=$((monRes[1] / 2))

# Rofi override to center window on screen
r_override="window { anchor: center; x-offset: -${x_pos_center}px; y-offset: -${y_pos_center}px; border: ${hypr_width}px; border-radius: 15px; } wallbox { border-radius: 10px; } element { border-radius: 10px; }"

# Notify the user about fetching Wi-Fi networks
notify-send "Searching for available Wi-Fi networks..."

# Get a list of available Wi-Fi connections and format it
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/  /g" | sed "s/^--/  /g" | sed "s/    / /g" | sed "/--/d")

# Check Wi-Fi status
connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "enabled" ]]; then
    toggle=" 󰤭  Disable Wi-Fi"
elif [[ "$connected" =~ "disabled" ]]; then
    toggle=" 󰤨  Enable Wi-Fi"
fi

# Use rofi to select Wi-Fi network
chosen_network=$(echo -e "   Manual Entry\n$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -theme-str "entry { placeholder: \"Search\"; }" -theme-str "${r_scale}" -theme-str "${r_override}" -config "${roconf}" -p "Wi-Fi SSID")

# Get the name of the connection
read -r chosen_id <<< "${chosen_network:3}"

# Perform actions based on the selected option
if [ "$chosen_network" = "" ]; then
    exit
elif [ "$chosen_network" = " 󰤨  Enable Wi-Fi" ]; then
    nmcli radio wifi on
elif [ "$chosen_network" = " 󰤭  Disable Wi-Fi" ]; then
    nmcli radio wifi off
elif [ "$chosen_network" = "   Manual Entry" ]; then
    # Prompt for manual SSID and password
    manual_ssid=$(rofi -dmenu -theme-str "entry { placeholder: \"SSID\"; }" -theme-str "${r_scale}" -theme-str "${r_override}" -config "${roconf}" -p "Enter SSID:")
    if [ -z "$manual_ssid" ]; then
        exit
    fi

    manual_password=$(rofi -dmenu -theme-str "entry { placeholder: \"Password\"; }" -theme-str "${r_scale}" -theme-str "${r_override}" -config "${roconf}" -p "Enter Password (optional):")
    
    if [ -z "$manual_password" ]; then
        nmcli device wifi connect "$manual_ssid"
    else
        nmcli device wifi connect "$manual_ssid" password "$manual_password"
    fi
else
    # Message to show when connection is activated successfully
    success_message="You are now connected to \"$chosen_id\"."
    
    # Get saved connections
    saved_connections=$(nmcli -g NAME connection)
    if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
        nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
    else
        if [[ "$chosen_network" =~ " " ]]; then
            wifi_password=$(rofi -dmenu -theme-str "entry { placeholder: \"Password: \"; }" -theme-str "${r_scale}" -theme-str "${r_override}" -config "${roconf}" -p "Password: ")
        fi
        nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
    fi
fi
