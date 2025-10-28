#!/usr/bin/env bash
#
# Scan, select, and connect to Wi-Fi networks
#
# Requirements:
# 	- nmcli (networkmanager)
# 	- fzf
# 	- notify-send (libnotify)
#
# Author: Jesse Mirabel <sejjymvm@gmail.com>
# Created: August 11, 2025
# License: MIT

RED='\033[1;31m'
RST='\033[0m'

TIMEOUT=5

get-network-list() {
	nmcli device wifi rescan 2> /dev/null

	local i
	for ((i = 1; i <= TIMEOUT; i++)); do
		printf '\rScanning for networks... (%d/%d)' $i $TIMEOUT
		printf '\033[1A' # move cursor up 1 line

		list=$(timeout 1 nmcli device wifi list)
		networks=$(tail -n +2 <<< "$list" | awk '$2 != "--"')

		[[ -n $networks ]] && break
	done

	printf '\n%bScanning stopped.%b\n\n' "$RED" "$RST"

	if [[ -z $networks ]]; then
		notify-send 'Wi-Fi' 'No networks found' -i 'package-broken'
		return 1
	fi
}

select-network() {
	local header
	header=$(head -n 1 <<< "$list")

	# shellcheck disable=SC1090
	. ~/.config/waybar/scripts/fzf-colors.sh 2> /dev/null

	local opts=(
		--border=sharp
		--border-label=' Wi-Fi Networks '
		--ghost='Search'
		--header="$header"
		--height=~100%
		--highlight-line
		--info=inline-right
		--pointer=
		--reverse
		"${COLORS[@]}"
	)

	bssid=$(fzf "${opts[@]}" <<< "$networks" | awk '{print $1}')

	if [[ -z $bssid ]]; then
		return 1
	elif [[ $bssid == '*' ]]; then
		notify-send 'Wi-Fi' 'Already connected to this network' \
			-i 'package-install'
		return 1
	fi
}

connect-to-network() {
	printf 'Connecting...\n'

	if nmcli --ask device wifi connect "$bssid"; then
		notify-send 'Wi-Fi' 'Successfully connected' -i 'package-install'
	else
		notify-send 'Wi-Fi' 'Failed to connect' -i 'package-purge'
	fi
}

main() {
	local status
	status=$(nmcli radio wifi)

	if [[ $status == 'disabled' ]]; then
		nmcli radio wifi on
		notify-send 'Wi-Fi Enabled' -i 'network-wireless-on' -r 1125
	fi

	tput civis # make cursor invisible
	get-network-list || exit 1
	tput cnorm # make cursor visible

	select-network || exit 1
	connect-to-network
}

main
