#!/usr/bin/env bash
#
# Connect to a Bluetooth device using bluetoothctl and fzf
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 19, 2025
# License: MIT

# shellcheck disable=SC1091
source "$HOME/.config/waybar/scripts/theme-switcher.sh" fzf

gray='\033[1;30m'
reset='\033[0m'

ensure-on() {
	local status
	status=$(bluetoothctl show | grep PowerState | awk '{print $2}')

	if [[ $status == 'off' ]]; then
		bluetoothctl power on >/dev/null
		notify-send 'Bluetooth On' -i 'network-bluetooth-activated' -r 1925
	fi
}

scan-for-devices() {
	local i n
	local s=10

	bluetoothctl --timeout $s scan on >/dev/null &

	for ((i = 1; i <= s; i++)); do
		echo -en "\rScanning for devices... " \
			"${gray}press [q] to stop${reset} ($i/$s)"
		echo -en '\033[s'

		n=$(bluetoothctl devices | grep -c Device)
		echo -en "\n\rDevices: $n"
		echo -en '\033[u'

		read -rs -n 1 -t 1

		if [[ $REPLY == 'q' ]]; then
			echo -en '\nScanning stopped'
			break
		fi
	done
}

get-device-list() {
	local list
	list=$(bluetoothctl devices | grep Device | cut -d' ' -f2-)

	if [[ -z $list ]]; then
		notify-send 'Bluetooth' 'No devices found' -i 'package-broken'
		return 1
	fi

	echo "$list"
}

select-device() {
	local list=$1
	local header opts address connected

	header=$(printf '%-17s %s' 'Address' 'Name')

	opts=(
		--border=sharp
		--border-label=' Bluetooth Devices '
		--ghost='Search'
		--header="$header"
		--height=~100%
		--highlight-line
		--info=inline-right
		--pointer=
		--reverse
	)
	opts+=("${COLORS[@]}")

	address=$(fzf "${opts[@]}" <<<"$list" | awk '{print $1}')

	if [[ -z $address ]]; then
		return 1
	fi

	connected=$(bluetoothctl info "$address" | grep Connected |
		awk '{print $2}')

	if [[ $connected == 'yes' ]]; then
		notify-send 'Bluetooth' 'Already connected to this device' \
			-i 'package-install'
		return 1
	else
		echo "$address"
	fi
}

pair-and-connect() {
	local address=$1
	local paired
	local s=10

	paired=$(bluetoothctl info "$address" | grep Paired | awk '{print $2}')

	if [[ $paired == 'no' ]]; then
		echo 'Pairing...'

		if ! timeout $s bluetoothctl pair "$address" >/dev/null; then
			notify-send 'Bluetooth' 'Failed to pair' -i 'package-purge'
			return 1
		fi
	fi

	echo 'Connecting...'

	if timeout $s bluetoothctl connect "$address" >/dev/null; then
		notify-send 'Bluetooth' 'Successfully connected' -i 'package-install'
	else
		notify-send 'Bluetooth' 'Failed to connect' -i 'package-purge'
	fi
}

main() {
	local list address

	ensure-on

	scan-for-devices
	list=$(get-device-list) || exit 1

	printf '\n\n\n'
	address=$(select-device "$list") || exit 1
	pair-and-connect "$address" || exit 1
}

main "$@"
