#!/usr/bin/env bash

# Send a notification when the battery is charging or discharging
#
# Add the following to /etc/udev/rules.d/50-power.rules (replace USERNAME with your username):
#
# ACTION=="change", SUBSYSTEM=="power_supply", ATTRS{type}=="Mains", ATTRS{online}=="0", RUN+="/usr/bin/su USERNAME -c '/home/USERNAME/.config/waybar/scripts/battery-state.sh discharging'"
# ACTION=="change", SUBSYSTEM=="power_supply", ATTRS{type}=="Mains", ATTRS{online}=="1", RUN+="/usr/bin/su USERNAME -c '/home/USERNAME/.config/waybar/scripts/battery-state.sh charging'"
#
# Reload udev rules by running the following command:
# sudo udevadm control --reload-rules
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 15, 2025
# License: MIT

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

battery_state=$1

# get the battery percentage using upower (waybar dependency)
battery_path=$(upower -e | grep BAT | head -n 1)
batt_level=$(upower -i "$battery_path" | awk '/percentage:/ {print $2}')

case $battery_state in
	"charging")
		batt_state="Charging"
		;;
	"discharging")
		batt_state="Discharging"
		;;
esac

notify-send "Battery ${batt_state} (${batt_level})" -r 50
