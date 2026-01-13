#!/usr/bin/env bash
#
# Scan, select, and connect to Wi-Fi networks
#
# Requirements:
# - nmcli (networkmanager)
# - fzf
# - notify-send (libnotify)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 11, 2025
# License: MIT

TIMEOUT=5

LIST=
NETWORKS=
BSSID=

cprintf() {
	printf "\e[31m%b\e[39m\n" "$@"
}

check_state() {
	local state
	state=$(nmcli radio wifi)

	[[ $state == "enabled" ]] && return 0

	nmcli radio wifi on

	local i new_state
	for ((i = 1; i <= TIMEOUT; i++)); do
		printf "\rEnabling Wi-Fi... (%d/%d)" $i $TIMEOUT

		new_state=$(nmcli -t -f STATE general)
		[[ $new_state != "connected (local only)" ]] && break

		sleep 1
	done

	notify-send "Wi-Fi Enabled" -i "network-wireless-on" \
		-h string:x-canonical-private-synchronous:network
}

get_networks() {
	nmcli device wifi rescan

	local i
	for ((i = 1; i <= TIMEOUT; i++)); do
		printf "\rScanning for networks... (%d/%d)" $i $TIMEOUT

		LIST=$(timeout 1 nmcli device wifi list)
		NETWORKS=$(tail -n +2 <<< "$LIST" | awk '$2 != "--"')

		[[ -n $NETWORKS ]] && break
	done

	cprintf "\nScanning stopped.\n"

	if [[ -z $NETWORKS ]]; then
		notify-send "Wi-Fi" "No networks found" -i "package-broken"
		exit 1
	fi
}

select_network() {
	local header
	header=$(head -n 1 <<< "$LIST")

	local options=(
		"--border=sharp"
		"--border-label= Wi-Fi Networks "
		"--ghost=Search"
		"--header=$header"
		"--height=~100%"
		"--highlight-line"
		"--info=inline-right"
		"--pointer="
		"--reverse"
	)

	BSSID=$(fzf "${options[@]}" <<< "$NETWORKS" | awk '{print $1}')
	case $BSSID in
		"") exit 1 ;;
		"*")
			notify-send "Wi-Fi" "Already connected to this network" \
				-i "package-install"
			exit 1
			;;
	esac
}

connect() {
	printf "Connecting...\n"

	if ! nmcli -a device wifi connect "$BSSID"; then
		notify-send "Wi-Fi" "Failed to connect" -i "package-purge"
		exit 1
	fi

	notify-send "Wi-Fi" "Successfully connected" -i "package-install"
}

main() {
	# hide cursor
	printf "\e[?25l"

	check_state
	get_networks

	# unhide cursor
	printf "\e[?25h"

	select_network
	connect
}

main
