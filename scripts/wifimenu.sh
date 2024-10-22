#!/bin/bash

# ---- Configuration Variables ----
border_width=2                            # Default border width for the window
font_size=10                              # Font size for Rofi
rofi_theme="$HOME/.config/rofi/wifi.rasi" # Path to the Rofi theme file

# ---- Monitor Info ----
# Get the resolution and scale factor of the currently focused monitor
readarray -t monitor_info < <(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width,.height,.scale')
scale_factor=${monitor_info[2]//./}                      # Remove any decimal from scale
monitor_width=$((monitor_info[0] * 100 / scale_factor))  # Adjust width based on scale
monitor_height=$((monitor_info[1] * 100 / scale_factor)) # Adjust height based on scale

# Calculate the center position for the Rofi window
center_x=$((monitor_width / 2))
center_y=$((monitor_height / 2))

# ---- Rofi Appearance Settings ----
# Style for Rofi (font size, border, and window centering)
rofi_font_style="configuration { font: \"JetBrainsMono Nerd Font ${font_size}\"; }"
rofi_window_style="window { anchor: center; x-offset: -${center_x}px; y-offset: -${center_y}px; border: ${border_width}px; border-radius: 15px; }"
rofi_element_style="element { border-radius: 10px; }"

# ---- Notify User ----
# Display a notification about scanning for Wi-Fi networks
notify-send "Searching for available Wi-Fi networks..."

# ---- Fetch Wi-Fi Networks ----
# Get a list of available Wi-Fi networks and format the output
wifi_networks=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/  /g" | sed "s/^--/  /g" | sed "s/    / /g" | sed "/--/d")

# ---- Wi-Fi Status (Enabled/Disabled) ----
# Check if Wi-Fi is enabled or disabled, and create toggle options
wifi_status=$(nmcli -fields WIFI g)
if [[ "$wifi_status" =~ "enabled" ]]; then
    wifi_toggle_option=" 󰤭  Disable Wi-Fi"
else
    wifi_toggle_option=" 󰤨  Enable Wi-Fi"
fi

# ---- Display Wi-Fi Networks in Rofi ----
# Show the list of Wi-Fi networks in Rofi, along with manual entry and Wi-Fi toggle options
selected_option=$(echo -e "   Manual Entry\n$wifi_toggle_option\n$wifi_networks" | uniq -u | rofi -dmenu -i -selected-row 1 -theme-str "entry { placeholder: \"Search...\"; }" -theme-str "${rofi_font_style}" -theme-str "${rofi_window_style}" -theme-str "${rofi_element_style}" -config "${rofi_theme}" -p "Wi-Fi SSID")

# Extract the SSID from the selected option (remove icons)
selected_ssid="${selected_option:3}"

# ---- Handle User Selection ----
if [ -z "$selected_option" ]; then
    exit # Exit if no option is selected
elif [ "$selected_option" = " 󰤨  Enable Wi-Fi" ]; then
    nmcli radio wifi on # Turn on Wi-Fi
elif [ "$selected_option" = " 󰤭  Disable Wi-Fi" ]; then
    nmcli radio wifi off # Turn off Wi-Fi
elif [ "$selected_option" = "   Manual Entry" ]; then
    # Handle manual SSID and password entry for connecting to a network
    manual_ssid=$(rofi -dmenu -theme-str "entry { placeholder: \"SSID\"; }" -theme-str "${rofi_font_style}" -theme-str "${rofi_window_style}" -theme-str "${rofi_element_style}" -config "${rofi_theme}" -p "Enter SSID:")
    if [ -z "$manual_ssid" ]; then
        exit # Exit if no SSID is entered
    fi

    # Prompt for a password (optional)
    manual_password=$(rofi -dmenu -theme-str "entry { placeholder: \"Password\"; }" -theme-str "${rofi_font_style}" -theme-str "${rofi_window_style}" -theme-str "${rofi_element_style}" -config "${rofi_theme}" -p "Enter Password (optional):")

    # Connect to the network with or without a password
    if [ -z "$manual_password" ]; then
        nmcli device wifi connect "$manual_ssid"
    else
        nmcli device wifi connect "$manual_ssid" password "$manual_password"
    fi
else
    # Connect to a selected network from the list
    success_message="You are now connected to \"$selected_ssid\"."

    # Check if the selected SSID is already saved
    saved_networks=$(nmcli -g NAME connection)
    if [[ $(echo "$saved_networks" | grep -w "$selected_ssid") = "$selected_ssid" ]]; then
        # Connect to the saved network
        nmcli connection up id "$selected_ssid" | grep "successfully" && notify-send "Connection Established" "$success_message"
    else
        # If the network is secured, prompt for a password
        if [[ "$selected_option" =~ " " ]]; then
            wifi_password=$(rofi -dmenu -theme-str "entry { placeholder: \"Password\"; }" -theme-str "${rofi_font_style}" -theme-str "${rofi_window_style}" -theme-str "${rofi_element_style}" -config "${rofi_theme}" -p "Password:")
        fi
        # Connect to the network with the provided password
        nmcli device wifi connect "$selected_ssid" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
    fi
fi
