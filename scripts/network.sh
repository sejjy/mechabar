#!/usr/bin/env bash
#
# Connect to a Wi-Fi network using nmcli and fzf
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 11, 2025
# License: MIT

# shellcheck disable=SC1091
source "$HOME/.config/waybar/scripts/theme-switcher.sh" fzf

RED='\033[1;31m'
RST='\033[0m'

TIMEOUT=5

ensure-enabled() {
	local status
	status=$(nmcli radio wifi)

	if [[ $status == 'disabled' ]]; then
		nmcli radio wifi on
		notify-send 'Wi-Fi Enabled' -i 'network-wireless-on' -r 1125
	fi
}

scan-for-networks() {
	local i list

	nmcli device wifi rescan 2>/dev/null

	for ((i = 1; i <= TIMEOUT; i++)); do
		echo -en "\rScanning for networks... ($i/$TIMEOUT)" >&2
		echo -en '\033[s'

		list=$(timeout 1 nmcli device wifi list)

		if [[ -n $list ]]; then
			break
		fi
	done

	echo -en "\n${RED}Scanning stopped.${RST}" >&2
	echo -en '\033[u'
	echo "$list"
}

get-network-list() {
	local list=$1
	local header

	header=$(head -n 1 <<<"$list")
	list=$(tail -n +2 <<<"$list" | awk '$2 != "--"')

	if [[ -z $list ]]; then
		notify-send 'Wi-Fi' 'No networks found' -i 'package-broken'
		return 1
	fi

	REPLY=("$header" "$list")
}

select-network() {
	local header=${REPLY[0]}
	local list=${REPLY[1]}
	local opts=("${COLORS[@]}")
	local bssid

	opts+=(
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

	bssid=$(fzf "${opts[@]}" <<<"$list" | awk '{print $1}')

	if [[ -z $bssid ]]; then
		return 1
	elif [[ $bssid == '*' ]]; then
		notify-send 'Wi-Fi' 'Already connected to this network' \
			-i 'package-install'
		return 1
	else
		echo "$bssid"
	fi
}

connect-to-network() {
	local bssid=$1

	echo -n 'Connecting...'

	if nmcli --ask device wifi connect "$bssid"; then
		notify-send 'Wi-Fi' 'Successfully connected' -i 'package-install'
	else
		notify-send 'Wi-Fi' 'Failed to connect' -i 'package-purge'
	fi
}

main() {
	local list bssid

	ensure-enabled
	list=$(scan-for-networks)
	get-network-list "$list" || exit 1

	printf '\n\n'

	bssid=$(select-network) || exit 1
	connect-to-network "$bssid"
}

main "$@"
