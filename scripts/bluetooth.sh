#!/usr/bin/env bash
#
# Connect to a Bluetooth device using bluetoothctl and fzf
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 19, 2025
# License: MIT

status=$(bluetoothctl show | grep PowerState | awk '{print $2}')

if [[ $status == 'off' ]]; then
	bluetoothctl power on >/dev/null
	notify-send 'Bluetooth On' -r 1925
fi

s=10
bluetoothctl --timeout $s scan on >/dev/null &

for i in {1..10}; do
	echo -en "\rScanning for devices... ($i/$s) (press 'q' to stop)"
	read -rs -n 1 -t 1

	if [[ $REPLY == 'q' ]]; then
		echo -en '\nScanning stopped'
		break
	fi
done

echo

list=$(bluetoothctl devices | grep Device | cut -d' ' -f2-)

if [[ -z $list ]]; then
	notify-send 'Bluetooth' 'No devices found'
	exit 1
fi

header=$(printf '%-17s %s' 'Address' 'Name')

# fzf options
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

mechadir="$HOME/.config/waybar"
source "$mechadir/scripts/theme-switcher.sh" fzf

options+=("${colors[@]}")

# extract the address of the selected device
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
