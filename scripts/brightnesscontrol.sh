#!/bin/bash

# Print error message for invalid arguments
print_error() {
    cat << "EOF"
Usage: ./brightnesscontrol.sh <action>
Valid actions are:
    i -- <i>ncrease brightness [+5%]
    d -- <d>ecrease brightness [-5%]
EOF
}

# Send a notification with brightness info
send_notification() {
    brightness=$(brightnessctl info | grep -oP "(?<=\()\d+(?=%)")
    notify-send -r 91190 "Brightness: ${brightness}%"
}

# Get the current brightness percentage
get_brightness() {
    brightnessctl -m | grep -o '[0-9]\+%' | head -c-2
}

# Handle options
while getopts o: opt; do
    case "${opt}" in
    o)
        case $OPTARG in
        i)  # Increase brightness
            if [[ $(get_brightness) -lt 10 ]] ; then
                brightnessctl set +1%
            else
                brightnessctl set +5%
            fi
            send_notification ;;
        d)  # Decrease brightness
            if [[ $(get_brightness) -le 1 ]] ; then
                brightnessctl set 1%
            elif [[ $(get_brightness) -le 10 ]] ; then
                brightnessctl set 1%-
            else
                brightnessctl set 5%-
            fi
            send_notification ;;
        *)
            print_error ;;
        esac
        ;;
    *)
        print_error ;;
    esac
done