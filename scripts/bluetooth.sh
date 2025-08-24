#!/usr/bin/env bash
#
# Connect to a Bluetooth device using bluetoothctl and fzf
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 19, 2025
# License: MIT

gray='\033[1;30m'
reset='\033[0m'

# shellcheck disable=SC1091
source "$HOME/.config/waybar/scripts/theme-switcher.sh" 'fzf'

status=$(bluetoothctl show | grep PowerState | awk '{print $2}')

if [[ $status == 'off' ]]; then
	bluetoothctl power on >/dev/null
	notify-send 'Bluetooth On' -r 1925
fi

s=10
bluetoothctl --timeout $s scan on >/dev/null &

for ((i = 1; i <= s; i++)); do
	echo -en "\rScanning for devices... ${gray}press q to stop${reset} ($i/$s)"
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

printf '\n\n\n'

list=$(bluetoothctl devices | grep Device | cut -d' ' -f2-)

if [[ -z $list ]]; then
	notify-send 'Bluetooth' 'No devices found'
	exit 1
fi

header=$(printf '%-17s %s' 'Address' 'Name')

options=(
	--border=sharp
	--border-label=' Bluetooth Devices '
	--ghost='Search'
	--height=~100%
	--header="$header"
	--highlight-line
	--info=inline-right
	--pointer=
	--reverse
)
# shellcheck disable=SC2154
options+=("${colors[@]}")

address=$(fzf "${options[@]}" <<<"$list" | awk '{print $1}')

[[ -z $address ]] && exit 0

connected=$(bluetoothctl info "$address" | grep Connected | awk '{print $2}')

if [[ $connected == 'yes' ]]; then
	notify-send 'Bluetooth' 'Already connected to this device'
	exit 0
fi

paired=$(bluetoothctl info "$address" | grep Paired | awk '{print $2}')

if [[ $paired == 'no' ]]; then
	echo 'Pairing...'

	if ! timeout $s bluetoothctl pair "$address" >/dev/null; then
		notify-send 'Bluetooth' 'Failed to pair'
		exit 1
	fi
fi

echo 'Connecting...'

if timeout $s bluetoothctl connect "$address" >/dev/null; then
	notify-send 'Bluetooth' 'Successfully connected'
else
	notify-send 'Bluetooth' 'Failed to connect'
fi
