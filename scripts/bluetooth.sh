#!/usr/bin/env bash
#
# Scan, select, pair, and connect to Bluetooth devices
#
# Requirements:
# 	bluetoothctl (bluez-utils)
# 	fzf
# 	notify-send (libnotify)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 19, 2025
# License: MIT

# shellcheck disable=SC1090
colors=()
source ~/.config/waybar/scripts/fzf-colorizer.sh &> /dev/null || true

RED="\e[31m"
RESET="\e[39m"

TIMEOUT=10

ensure-on() {
	local state
	state=$(bluetoothctl show | awk '/PowerState/ {print $2}')

	case $state in
		"off") bluetoothctl power on > /dev/null ;;
		"off-blocked")
			rfkill unblock bluetooth

			local i new_state
			for ((i = 1; i <= TIMEOUT; i++)); do
				printf "\rUnblocking Bluetooth... (%d/%d)" $i $TIMEOUT

				new_state=$(bluetoothctl show | awk '/PowerState/ {print $2}')
				if [[ $new_state == "on" ]]; then
					break
				fi

				sleep 1
			done

			if [[ $new_state != "on" ]]; then
				notify-send "Bluetooth" "Failed to unblock" -i "package-purge"
				return 1
			fi
			;;
		*) return 0 ;;
	esac

	notify-send "Bluetooth On" -i "network-bluetooth-activated" \
		-h string:x-canonical-private-synchronous:bluetooth
}

get-device-list() {
	bluetoothctl -t $TIMEOUT scan on > /dev/null &

	local i num
	for ((i = 1; i <= TIMEOUT; i++)); do
		printf "\rScanning for devices... (%d/%d)\n" $i $TIMEOUT
		printf "%bPress [q] to stop%b\n" "$RED" "$RESET"

		num=$(bluetoothctl devices | grep -c "Device")
		printf "\nDevices: %s" "$num"
		printf "\e[0;0H"

		read -rsn 1 -t 1
		if [[ $REPLY == [Qq] ]]; then
			break
		fi
	done

	printf "\n%bScanning stopped.%b\n\n" "$RED" "$RESET"

	list=$(bluetoothctl devices | sed "s/^Device //")
	if [[ -z $list ]]; then
		notify-send "Bluetooth" "No devices found" -i "package-broken"
		return 1
	fi
}

select-device() {
	local header
	header=$(printf "%-17s %s" "Address" "Name")

	local options=(
		"--border=sharp"
		"--border-label= Bluetooth Devices "
		"--ghost=Search"
		"--header=$header"
		"--height=~100%"
		"--highlight-line"
		"--info=inline-right"
		"--pointer="
		"--reverse"
		"${colors[@]}"
	)

	address=$(fzf "${options[@]}" <<< "$list" | awk '{print $1}')
	if [[ -z $address ]]; then
		return 1
	fi

	local connected
	connected=$(bluetoothctl info "$address" | awk '/Connected/ {print $2}')

	if [[ $connected == "yes" ]]; then
		notify-send "Bluetooth" "Already connected to this device" \
			-i "package-install"
		return 1
	fi
}

pair-and-connect() {
	local paired
	paired=$(bluetoothctl info "$address" | awk '/Paired/ {print $2}')

	if [[ $paired == "no" ]]; then
		printf "Pairing..."

		if ! timeout $TIMEOUT bluetoothctl pair "$address" > /dev/null; then
			notify-send "Bluetooth" "Failed to pair" -i "package-purge"
			return 1
		fi
	fi

	printf "\nConnecting..."

	if ! timeout $TIMEOUT bluetoothctl connect "$address" > /dev/null; then
		notify-send "Bluetooth" "Failed to connect" -i "package-purge"
		return 1
	fi

	notify-send "Bluetooth" "Successfully connected" -i "package-install"
}

main() {
	printf "\e[?25l"
	ensure-on || exit 1
	get-device-list || exit 1
	printf "\e[?25h"
	select-device || exit 1
	pair-and-connect || exit 1
}

main
