#!/usr/bin/env bash
#
# Scan, select, pair, and connect to Bluetooth devices
#
# Requirements:
# 	- bluetoothctl (bluez-utils)
# 	- fzf
# 	- notify-send (libnotify)
#
# Author: Jesse Mirabel <sejjymvm@gmail.com>
# Created: August 19, 2025
# License: MIT

fcconf=()
# Get fzf color config
# shellcheck disable=SC1090,SC2154
. ~/.config/waybar/scripts/_fzf-colorizer.sh 2> /dev/null || true
# If the file is missing, fzf will fall back to its default colors

RED='\033[1;31m'
RST='\033[0m'

TIMEOUT=10

ensure-on() {
	local status
	status=$(bluetoothctl show | grep PowerState | awk '{print $2}')
	if [[ $status == 'off' ]]; then
		bluetoothctl power on > /dev/null
		notify-send 'Bluetooth On' -i 'network-bluetooth-activated' -r 1925
	fi
}

get-device-list() {
	bluetoothctl --timeout $TIMEOUT scan on > /dev/null &

	local i num
	for ((i = 1; i <= TIMEOUT; i++)); do
		printf '\rScanning for devices... (%d/%d)' $i $TIMEOUT
		printf '\n%bPress [q] to stop%b\n\n' "$RED" "$RST"

		num=$(bluetoothctl devices | grep -c Device)
		printf '\rDevices: %s' "$num"
		printf '\033[3A'

		read -rs -n 1 -t 1
		if [[ $REPLY == [Qq] ]]; then
			break
		fi
	done
	printf '\n%bScanning stopped.%b\n\n' "$RED" "$RST"

	list=$(bluetoothctl devices | grep Device | cut -d ' ' -f 2-)
	if [[ -z $list ]]; then
		notify-send 'Bluetooth' 'No devices found' -i 'package-broken'
		return 1
	fi
}

select-device() {
	local header
	header=$(printf '%-17s %s' 'Address' 'Name')
	local opts=(
		'--border=sharp'
		'--border-label= Bluetooth Devices '
		'--ghost=Search'
		"--header=$header"
		'--height=~100%'
		'--highlight-line'
		'--info=inline-right'
		'--pointer='
		'--reverse'
		"${fcconf[@]}"
	)

	address=$(fzf "${opts[@]}" <<< "$list" | awk '{print $1}')
	if [[ -z $address ]]; then
		return 1
	fi

	local connected
	connected=$(bluetoothctl info "$address" | grep Connected |
		awk '{print $2}')
	if [[ $connected == 'yes' ]]; then
		notify-send 'Bluetooth' 'Already connected to this device' \
			-i 'package-install'
		return 1
	fi
}

pair-and-connect() {
	local paired
	paired=$(bluetoothctl info "$address" | grep Paired | awk '{print $2}')
	if [[ $paired == 'no' ]]; then
		printf 'Pairing...'
		if ! timeout $TIMEOUT bluetoothctl pair "$address" > /dev/null; then
			notify-send 'Bluetooth' 'Failed to pair' -i 'package-purge'
			return 1
		fi
	fi

	printf '\nConnecting...'
	if ! timeout $TIMEOUT bluetoothctl connect "$address" > /dev/null; then
		notify-send 'Bluetooth' 'Failed to connect' -i 'package-purge'
		return 1
	fi
	notify-send 'Bluetooth' 'Successfully connected' -i 'package-install'
}

main() {
	tput civis
	ensure-on
	get-device-list || exit 1
	tput cnorm
	select-device || exit 1
	pair-and-connect || exit 1
}

main
