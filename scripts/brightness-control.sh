#!/usr/bin/env bash

# Print error message for invalid arguments
print_error() {
  cat <<"EOF"
Usage: ./brightnesscontrol.sh <action>
Valid actions are:
    i -- <i>ncrease brightness [+2%]
    d -- <d>ecrease brightness [-2%]
EOF
}

# Send a notification with brightness info
send_notification() {
  brightness=$(brightnessctl info | grep -oP "(?<=\()\d+(?=%)")
  notify-send -a "state" -r 91190 -i "gpm-brightness-lcd" -h int:value:"$brightness" "Brightness: ${brightness}%" -u low
}

# Get the current brightness percentage and device name
get_brightness() {
  brightness=$(brightnessctl -m | grep -o '[0-9]\+%' | head -c-2)
  device=$(brightnessctl -m | head -n 1 | awk -F',' '{print $1}' | sed 's/_/ /g; s/\<./\U&/g') # Get device name
  current_brightness=$(brightnessctl -m | head -n 1 | awk -F',' '{print $3}')                  # Get current brightness
  max_brightness=$(brightnessctl -m | head -n 1 | awk -F',' '{print $5}')                      # Get max brightness
}
get_brightness

# Handle options
while getopts o: opt; do
  case "${opt}" in
  o)
    case $OPTARG in
    i) # Increase brightness
      if [[ $brightness -lt 10 ]]; then
        brightnessctl set +1%
      else
        brightnessctl set +2%
      fi
      send_notification
      ;;
    d) # Decrease brightness
      if [[ $brightness -le 1 ]]; then
        brightnessctl set 1%
      elif [[ $brightness -le 10 ]]; then
        brightnessctl set 1%-
      else
        brightnessctl set 2%-
      fi
      send_notification
      ;;
    *)
      print_error
      ;;
    esac
    ;;
  *)
    print_error
    ;;
  esac
done

# Determine the icon based on brightness level
get_icon() {
  if ((brightness <= 5)); then
    icon=""
  elif ((brightness <= 15)); then
    icon=""
  elif ((brightness <= 30)); then
    icon=""
  elif ((brightness <= 45)); then
    icon=""
  elif ((brightness <= 55)); then
    icon=""
  elif ((brightness <= 65)); then
    icon=""
  elif ((brightness <= 80)); then
    icon=""
  elif ((brightness <= 95)); then
    icon=""
  else
    icon=""
  fi
}

# Backlight module and tooltip
get_icon
module="${icon} ${brightness}%"

tooltip="Device Name: ${device}"
tooltip+="\nBrightness:  ${current_brightness} / ${max_brightness}"

echo "{\"text\": \"${module}\", \"tooltip\": \"${tooltip}\"}"
