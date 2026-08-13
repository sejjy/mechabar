#!/usr/bin/env bash
#
# Connect to a Wi-Fi network
#
# Dependencies:
#   - fzf
#   - libnotify (notify-send)
#   - networkmanager (nmcli)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 11, 2025
# License: MIT

TIMEOUT=10

RESET=$'\e[0m'
DIM=$'\e[2m'

usage() {
	cat <<-EOF
		USAGE: ${0##*/} [option]

		Connect to a Wi-Fi network

		OPTIONS:
		  off       Turn Wi-Fi off
		  <none>    Turn Wi-Fi on and launch the CLI
	EOF
}

debug() { printf "%b" "$*" >&2; }

hide_cursor() { debug $'\e[?25l'; }
show_cursor() { debug $'\e[?25h'; }

turn_off() {
	nmcli radio wifi off
	notify-send "Wi-Fi Off" -i "network-wireless-off" \
		-h string:x-canonical-private-synchronous:network
}

turn_on() {
	local init
	init=$(nmcli radio wifi)

	if [[ $init == enabled ]]; then
		return 0
	fi

	nmcli radio wifi on

	local state
	local s
	for ((s = 1; s <= TIMEOUT; s++)); do
		debug "\rTurning on Wi-Fi... ($s/$TIMEOUT)"

		state=$(nmcli radio wifi)

		if [[ $state == enabled ]]; then
			break
		fi

		sleep 1
	done

	if [[ $state != enabled ]]; then
		notify-send "Wi-Fi" "Failed to turn on" -i "package-purge"
		exit 1
	fi

	notify-send "Wi-Fi On" -i "network-wireless-on" \
		-h string:x-canonical-private-synchronous:network
}

get_networks() {
	nmcli device wifi rescan

	local s
	for ((s = 1; s <= TIMEOUT; s++)); do
		debug "\rScanning for networks... ($s/$TIMEOUT)"

		LIST=$(nmcli device wifi list)
		NETWORKS=$(tail -n +2 <<<"$LIST" | awk '$2 != "--"')

		if [[ -n $NETWORKS ]]; then
			break
		fi

		sleep 1
	done

	debug "\n\n"

	if [[ -z $NETWORKS ]]; then
		notify-send "Wi-Fi" "No networks found" -i "package-broken"
		exit 1
	fi
}

select_network() {
	local header
	header=$(head -n 1 <<<"$LIST")

	local options=(
		"--border=sharp"
		"--border-label= Wi-Fi Networks "
		"--cycle"
		"--ghost=Search"
		"--header=$header"
		"--height=~100%"
		"--highlight-line"
		"--info=inline-right"
		"--pointer="
		"--reverse"
	)

	BSSID=$(fzf "${options[@]}" <<<"$NETWORKS" | awk '{print $1}')

	if [[ -z $BSSID ]]; then
		exit 1
	fi
}

connect_network() {
	if [[ $BSSID == '*' ]]; then
		notify-send "Wi-Fi" "Already connected to this network" \
			-i "package-install"
		exit 0
	fi

	debug "Connecting...\n"

	if ! nmcli -a device wifi connect "$BSSID"; then
		notify-send "Wi-Fi" "Failed to connect" -i "package-purge"
		exit 1
	fi

	notify-send "Wi-Fi" "Successfully connected" -i "package-install"
}

main() {
	local option=$1

	case $option in
		off)
			turn_off
			return 0
			;;
		'')
			hide_cursor
			trap 'show_cursor' EXIT

			turn_on
			get_networks

			show_cursor
			trap - EXIT

			select_network
			connect_network
			;;
		*)
			usage >&2
			return 1
			;;
	esac
}

main "$@"
