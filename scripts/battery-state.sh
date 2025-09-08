#!/usr/bin/env bash
#
# Send a notification when the battery state changes using udev rules
#
# Add the following to /etc/udev/rules.d/60-power.rules
# (replace <username> with your actual username):
#
# ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/su <username> --command '~/.config/waybar/scripts/battery-state.sh charging'"
# ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/su <username> --command '~/.config/waybar/scripts/battery-state.sh discharging'"
#
# Reload udev rules by running:
# sudo udevadm control --reload
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 15, 2025
# License: MIT

export DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/1000/bus'

state=$1
case $state in
	'charging')
		state=${state^}
		icon='battery-100-charging'
		;;
	'discharging')
		state=${state^}
		icon='battery-100'
		;;
esac

path=$(upower -e | grep BAT | head -n 1)
level=$(upower -i "$path" | awk '/percentage:/ {print $2}')

notify-send "Battery $state ($level)" -i "$icon" -r 1525
