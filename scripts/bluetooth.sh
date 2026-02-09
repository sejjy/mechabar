#!/usr/bin/env bash
#
# Scan, select, pair, and connect to Bluetooth devices
#
# Requirements:
# - bluetoothctl (bluez-utils)
# - fzf
# - notify-send (libnotify)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 19, 2025
# License: MIT

FG_RED="\e[31m"
FG_RESET="\e[39m"

TIMEOUT=10

printf() {
	command printf "$@" >&2
}

power_on() {
	local state
	state=$(bluetoothctl show | awk '/PowerState/ {print $2}')

	case $state in
		off)
			bluetoothctl power on > /dev/null
			;;
		off-blocked)
			rfkill unblock bluetooth

			local new_state

			local i=1
			for ((; i <= TIMEOUT; i++)); do
				printf "\rUnblocking Bluetooth... (%d/%d)" $i $TIMEOUT

				new_state=$(bluetoothctl show | awk '/PowerState/ {print $2}')
				if [[ $new_state == on ]]; then
					break
				fi

				sleep 1
			done

			if [[ $new_state != on ]]; then
				notify-send "Bluetooth" "Failed to unblock" -i "package-purge"
				exit 1
			fi
			;;
		*)
			return 0
			;;
	esac

	notify-send "Bluetooth On" -i "network-bluetooth-activated" \
		-h string:x-canonical-private-synchronous:bluetooth
}

get_devices() {
	bluetoothctl -t $TIMEOUT scan on > /dev/null &

	local num

	local i=1
	for ((; i <= TIMEOUT; i++)); do
		printf "\rScanning for devices... (%d/%d)" $i $TIMEOUT
		printf "\n%bPress [q] to stop%b\n" "$FG_RED" "$FG_RESET"

		num=$(bluetoothctl devices | grep -c "Device")
		printf "\nDevices: %d" "$num"

		# move cursor 3 lines up
		printf "\e[3F"

		read -rsn 1 -t 1
		if [[ $REPLY == [Qq] ]]; then
			break
		fi
	done

	printf "\n%bScanning stopped.%b\n\n" "$FG_RED" "$FG_RESET"

	LIST=$(bluetoothctl devices | sed "s/^Device //")
	if [[ -z $LIST ]]; then
		notify-send "Bluetooth" "No devices found" -i "package-broken"
		exit 1
	fi
}

select_device() {
	local header
	printf -v header "%-17s %s" "Address" "Name"

	local options=(
		"--border=sharp"
		"--border-label= Bluetooth Devices "
		"--cycle"
		"--ghost=Search"
		"--header=$header"
		"--height=~100%"
		"--highlight-line"
		"--info=inline-right"
		"--pointer="
		"--reverse"
	)

	ADDRESS=$(fzf "${options[@]}" <<< "$LIST" | awk '{print $1}')
	if [[ -z $ADDRESS ]]; then
		exit 1
	fi

	local connected
	connected=$(bluetoothctl info "$ADDRESS" | awk '/Connected/ {print $2}')

	if [[ $connected == yes ]]; then
		notify-send "Bluetooth" "Already connected to this device" \
			-i "package-install"
		exit 1
	fi
}

pair_and_connect() {
	local paired
	paired=$(bluetoothctl info "$ADDRESS" | awk '/Paired/ {print $2}')

	if [[ $paired == no ]]; then
		printf "Pairing..."

		if ! timeout $TIMEOUT bluetoothctl pair "$ADDRESS" > /dev/null; then
			notify-send "Bluetooth" "Failed to pair" -i "package-purge"
			exit 1
		fi
	fi

	printf "\nConnecting..."

	if ! timeout $TIMEOUT bluetoothctl connect "$ADDRESS" > /dev/null; then
		notify-send "Bluetooth" "Failed to connect" -i "package-purge"
		exit 1
	fi

	notify-send "Bluetooth" "Successfully connected" -i "package-install"
}

main() {
	# make cursor invisible
	printf "\e[?25l"

	power_on
	get_devices

	# make cursor visible
	printf "\e[?25h"

	select_device
	pair_and_connect
}

main
