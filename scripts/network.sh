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

fcconf=()
# Get fzf color config
# shellcheck disable=SC1090,SC2154
. ~/.config/waybar/scripts/_fzf_colorizer.sh 2> /dev/null || true
# If the file is missing, fzf will fall back to its default colors

RED='\033[1;31m'
RST='\033[0m'

TIMEOUT=5

ensure-enabled() {
	local radio
	radio=$(nmcli radio wifi)
	if [[ $radio == 'enabled' ]]; then
		return 0
	fi
	nmcli radio wifi on

	local i state
	for ((i = 1; i <= TIMEOUT; i++)); do
		printf '\rEnabling Wi-Fi... (%d/%d)' $i $TIMEOUT

		state=$(nmcli -t -f STATE general)
		# If STATE returns anything other than this, we assume that Wi-Fi is
		# fully enabled
		if [[ $state != 'connected (local only)' ]]; then
			break
		fi
		sleep 1
	done
	notify-send 'Wi-Fi Enabled' -i 'network-wireless-on' -r 1125
}

get-network-list() {
	nmcli device wifi rescan

	local i
	for ((i = 1; i <= TIMEOUT; i++)); do
		printf '\rScanning for networks... (%d/%d)' $i $TIMEOUT

		list=$(timeout 1 nmcli device wifi list)
		networks=$(tail -n +2 <<< "$list" | awk '$2 != "--"')
		if [[ -n $networks ]]; then
			break
		fi
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
	local opts=(
		'--border=sharp'
		'--border-label= Wi-Fi Networks '
		'--ghost=Search'
		"--header=$header"
		'--height=~100%'
		'--highlight-line'
		'--info=inline-right'
		'--pointer='
		'--reverse'
		"${fcconf[@]}"
	)

	bssid=$(fzf "${opts[@]}" <<< "$networks" | awk '{print $1}')
	if [[ -z $bssid ]]; then
		return 1
	fi
	if [[ $bssid == '*' ]]; then
		notify-send 'Wi-Fi' 'Already connected to this network' \
			-i 'package-install'
		return 1
	fi
}

connect-to-network() {
	printf 'Connecting...\n'
	if ! nmcli --ask device wifi connect "$bssid"; then
		notify-send 'Wi-Fi' 'Failed to connect' -i 'package-purge'
		return 1
	fi
	notify-send 'Wi-Fi' 'Successfully connected' -i 'package-install'
}

main() {
	tput civis
	ensure-enabled || exit 1
	get-network-list || exit 1
	tput cnorm
	select-network || exit 1
	connect-to-network || exit 1
}

main
