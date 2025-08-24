#!/usr/bin/env bash
#
# Connect to a Wi-Fi network using nmcli and fzf
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 11, 2025
# License: MIT

# shellcheck disable=SC1091
source "$HOME/.config/waybar/scripts/theme-switcher.sh" 'fzf'

status=$(nmcli radio wifi)

if [[ $status == 'disabled' ]]; then
	nmcli radio wifi on
	notify-send 'Wi-Fi Enabled' -r 1125
fi

nmcli device wifi rescan 2>/dev/null

s=5
for ((i = 1; i <= s; i++)); do
	echo -en "\rScanning for networks... ($i/$s)"

	output=$(timeout 1 nmcli device wifi list)
	list=$(tail -n +2 <<<"$output" | awk '$2 != "--"')

	[[ -n $list ]] && break
done

printf '\n\n'

if [[ -z $list ]]; then
	notify-send 'Wi-Fi' 'No networks found'
	exit 1
fi

header=$(head -n 1 <<<"$output")

options=(
	--border=sharp
	--border-label=' Wi-Fi Networks '
	--ghost='Search'
	--header="$header"
	--height=~100%
	--highlight-line
	--info=inline-right
	--pointer=
	--reverse
)
# shellcheck disable=SC2154
options+=("${colors[@]}")

bssid=$(fzf "${options[@]}" <<<"$list" | awk '{print $1}')

[[ -z $bssid ]] && exit 0

if [[ $bssid == '*' ]]; then
	notify-send 'Wi-Fi' 'Already connected to this network'
	exit 0
fi

echo 'Connecting...'

if nmcli device wifi connect "$bssid" --ask; then
	notify-send 'Wi-Fi' 'Successfully connected'
else
	notify-send 'Wi-Fi' 'Failed to connect'
fi
