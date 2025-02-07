#!/usr/bin/env bash

# Original script by Eric Murphy
# https://github.com/ericmurphyxyz/dotfiles/blob/master/.local/bin/battery-alert
#
# Modified by Jesse Mirabel (@sejjy)
# https://github.com/sejjy/mechabar

# This script sends a notification when the battery is charging or discharging.
# icon theme used: tela-circle-icon-theme-dracula
#
# (see the bottom of the script for more information)

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

# get the battery state from the udev rule
BATTERY_STATE=$1

# get the battery percentage using upower (waybar dependency)
BAT_PATH=$(upower -e | grep BAT | head -n 1)
BATTERY_LEVEL=$(upower -i "$BAT_PATH" | awk '/percentage:/ {print $2}' | tr -d '%')

# set the battery charging state and icon
case "$BATTERY_STATE" in
"charging")
  BATTERY_CHARGING="Charging"
  BATTERY_ICON="090-charging"
  ;;
"discharging")
  BATTERY_CHARGING="Disharging"
  BATTERY_ICON="090"
  ;;
esac

# send the notification
notify-send -a "state" "Battery ${BATTERY_CHARGING} (${BATTERY_LEVEL}%)" -u normal -i "battery-${BATTERY_ICON}" -r 9991

# udev rule
# Add the following to /etc/udev/rules.d/60-power.rules:

# ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", ENV{DISPLAY}=":0", RUN+="/usr/bin/su <username> -c '$HOME/.config/waybar/scripts/battery-state.sh discharging'"
# ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", ENV{DISPLAY}=":0", RUN+="/usr/bin/su <username> -c '$HOME/.config/waybar/scripts/battery-state.sh charging'"

# the number 60 in the udev rule can be changed to any number between 0 and 99.
# the lower the number, the higher the priority.
#
# $USER does not work, so you have to replace "<username>" with your username.

# reload udev rules by running the following command:
# sudo udevadm control --reload-rules
