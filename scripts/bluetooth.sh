#!/usr/bin/env bash
#
# Connect to a Bluetooth device using bluetoothctl and fzf
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 19, 2025
# License: MIT

# shellcheck disable=SC1091
source "$HOME/.config/waybar/scripts/theme-switcher.sh" fzf

RED='\033[1;31m'
RST='\033[0m'

TIMEOUT=10

ensure-on() {
	local status
	status=$(bluetoothctl show | grep PowerState | awk '{print $2}')

	if [[ $status == 'off' ]]; then
		bluetoothctl power on >/dev/null
		notify-send 'Bluetooth On' -i 'network-bluetooth-activated' -r 1925
	fi
}

scan-for-devices() {
	local i num

	bluetoothctl --timeout $TIMEOUT scan on >/dev/null &

	for ((i = 1; i <= TIMEOUT; i++)); do
		echo -en "\rScanning for devices... ($i/$TIMEOUT)"
		echo -en '\033[s'
		echo -en "\n${RED}Press [q] to stop${RST}"

		num=$(bluetoothctl devices | grep -c Device)
		echo -en "\n\n\rDevices: $num"
		echo -en '\033[u'

		read -rs -n 1 -t 1
		if [[ $REPLY == [Qq] ]]; then
			break
		fi
	done

	echo -en "\n${RED}Scanning stopped.${RST}"
	echo -en '\033[u'
}

get-device-list() {
	local list
	list=$(bluetoothctl devices | grep Device | cut -d ' ' -f 2-)

	if [[ -z $list ]]; then
		notify-send 'Bluetooth' 'No devices found' -i 'package-broken'
		return 1
	fi

	echo "$list"
}

select-device() {
	local list=$1
	local opts=("${COLORS[@]}")
	local header address connected

	header=$(printf '%-17s %s' 'Address' 'Name')

	opts+=(
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

	paired=$(bluetoothctl info "$address" | grep Paired | awk '{print $2}')

	if [[ $paired == 'no' ]]; then
		echo -n 'Pairing...'

		if ! timeout $TIMEOUT bluetoothctl pair "$address" >/dev/null; then
			notify-send 'Bluetooth' 'Failed to pair' -i 'package-purge'
			return 1
		fi
	fi

	echo -en '\nConnecting...'

	if timeout $TIMEOUT bluetoothctl connect "$address" >/dev/null; then
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
