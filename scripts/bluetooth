#!/usr/bin/env bash
#
# Connect to a Bluetooth device
#
# Dependencies:
#   - bluez-utils (bluetoothctl)
#   - fzf
#   - libnotify (notify-send)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 19, 2025
# License: MIT

TIMEOUT=10

RESET=$'\e[0m'
DIM=$'\e[2m'

usage() {
	cat <<-EOF
		USAGE: ${0##*/} [option]

		Connect to a Bluetooth device

		OPTIONS:
		  off       Turn Bluetooth off
		  <none>    Turn Bluetooth on and launch the CLI
	EOF
}

debug() { printf "%b" "$*" >&2; }

hide_cursor() { debug $'\e[?25l'; }
show_cursor() { debug $'\e[?25h'; }

turn_off() {
	bluetoothctl power off
	notify-send "Bluetooth Off" -i "network-bluetooth-inactive" \
		-h string:x-canonical-private-synchronous:bluetooth
}

turn_on() {
	local init
	init=$(bluetoothctl show | awk '/PowerState/ {print $2}')

	case $init in
		on)
			return 0
			;;
		off)
			bluetoothctl power on >/dev/null
			;;
		off-blocked)
			rfkill unblock bluetooth
			;;
	esac

	local state
	local s
	for ((s = 1; s <= TIMEOUT; s++)); do
		debug "\rTurning on Bluetooth... ($s/$TIMEOUT)"

		state=$(bluetoothctl show | awk '/PowerState/ {print $2}')

		if [[ $state == on ]]; then
			break
		fi

		sleep 1
	done

	if [[ $state != on ]]; then
		notify-send "Bluetooth" "Failed to turn on" -i "package-purge"
		exit 1
	fi

	notify-send "Bluetooth On" -i "network-bluetooth-activated" \
		-h string:x-canonical-private-synchronous:bluetooth
}

get_devices() {
	bluetoothctl -t $TIMEOUT scan on >/dev/null &

	local count
	local s
	for ((s = 1; s <= TIMEOUT; s++)); do
		debug "\rScanning for devices... ($s/$TIMEOUT) ${DIM}[q]${RESET}"

		count=$(bluetoothctl devices | grep -c '^Device')

		debug "\n\n${DIM}Devices: $count${RESET}\e[2F"

		read -rsn 1 -t 1

		if [[ $REPLY == [Qq] ]]; then
			break
		fi
	done

	debug "\n\n"

	LIST=$(bluetoothctl devices | sed 's/^Device //')

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

	ADDRESS=$(fzf "${options[@]}" <<<"$LIST" | awk '{print $1}')

	if [[ -z $ADDRESS ]]; then
		exit 1
	fi
}

pair_device() {
	local paired
	paired=$(bluetoothctl info "$ADDRESS" | awk '/Paired/ {print $2}')

	if [[ $paired == yes ]]; then
		return 0
	fi

	debug "Pairing...\n"

	if ! timeout $TIMEOUT bluetoothctl pair "$ADDRESS" >/dev/null; then
		notify-send "Bluetooth" "Failed to pair" -i "package-purge"
		exit 1
	fi
}

connect_device() {
	local connected
	connected=$(bluetoothctl info "$ADDRESS" | awk '/Connected/ {print $2}')

	if [[ $connected == yes ]]; then
		notify-send "Bluetooth" "Already connected to this device" \
			-i "package-install"
		exit 0
	fi

	pair_device

	debug "Connecting...\n"

	if ! timeout $TIMEOUT bluetoothctl connect "$ADDRESS" >/dev/null; then
		notify-send "Bluetooth" "Failed to connect" -i "package-purge"
		exit 1
	fi

	notify-send "Bluetooth" "Successfully connected" -i "package-install"
}

main() {
	local option=$1

	case $option in
		off)
			turn_off
			return 0
			;;
		'')
			hide_cursor
			trap 'show_cursor' EXIT

			turn_on
			get_devices

			show_cursor
			trap - EXIT

			select_device
			connect_device
			;;
		*)
			usage >&2
			return 1
			;;
	esac
}

main "$@"
