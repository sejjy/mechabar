#!/usr/bin/env bash
#
# Send a notification when the battery state changes using udev rules
#
# Add the following to /etc/udev/rules.d/60-power.rules
# and replace <username> with your actual username:
#
# ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/su <username> -c '~/.config/waybar/scripts/battery-state.sh charging'"
# ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/su <username> -c '~/.config/waybar/scripts/battery-state.sh discharging'"
#
# Reload udev rules by running:
# sudo udevadm control --reload
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 15, 2025
# License: MIT

export DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/1000/bus'

get-level() {
	local path level

	path=$(upower -e | grep BAT | head -n 1)
	level=$(upower -i "$path" | awk '/percentage:/ {print $2}' | tr -d '%')

	echo "$level"
}

get-icon() {
	local level=$1
	local icon='battery-'

	if ((level == 100)); then
		icon+='100'
	else
		level=$(((level / 10) * 10))
		icon+=$(printf '%03d' "$level")
	fi

	echo "$icon"
}

main() {
	local state=${1^}
	local level icon

	level=$(get-level)
	icon=$(get-icon "$level")

	if [[ $state == 'Charging' ]]; then
		icon+='-charging'
	fi

	notify-send "Battery $state (${level}%)" -i "$icon" -r 1525
}

main "$@"
