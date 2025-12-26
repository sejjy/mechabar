#!/usr/bin/env bash
#
# Scan, select, and connect to Wi-Fi networks
#
# Requirements:
# 	nmcli (networkmanager)
# 	fzf
# 	notify-send (libnotify)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 11, 2025
# License: MIT

# shellcheck disable=SC1090
colors=()
source ~/.config/waybar/scripts/fzf-theme.sh &> /dev/null || true

RED="\e[31m"
RESET="\e[39m"

TIMEOUT=5

ensure-enabled() {
	local s; s=$(nmcli radio wifi)
	if [[ $s == "enabled" ]]; then
		return 0
	fi

	nmcli radio wifi on

	local i state
	for ((i = 1; i <= TIMEOUT; i++)); do
		printf "\rEnabling Wi-Fi... (%d/%d)" $i $TIMEOUT

		state=$(nmcli -t -f STATE general)
		# If STATE returns anything other than this, we assume that Wi-Fi is
		# fully enabled
		if [[ $state != "connected (local only)" ]]; then
			break
		fi

		sleep 1
	done

	notify-send "Wi-Fi Enabled" -i "network-wireless-on" \
		-h string:x-canonical-private-synchronous:network
}

get-network-list() {
	nmcli device wifi rescan

	local i
	for ((i = 1; i <= TIMEOUT; i++)); do
		printf "\rScanning for networks... (%d/%d)" $i $TIMEOUT

		list=$(timeout 1 nmcli device wifi list)
		networks=$(tail -n +2 <<< "$list" | awk '$2 != "--"')

		if [[ -n $networks ]]; then
			break
		fi
	done

	printf "\n%bScanning stopped.%b\n" "$RED" "$RESET"
	printf "\e[1B"

	if [[ -z $networks ]]; then
		notify-send "Wi-Fi" "No networks found" -i "package-broken"
		return 1
	fi
}

select-network() {
	local header; header=$(head -n 1 <<< "$list")
	local opts=(
		"--border=sharp"
		"--border-label= Wi-Fi Networks "
		"--ghost=Search"
		"--header=$header"
		"--height=~100%"
		"--highlight-line"
		"--info=inline-right"
		"--pointer="
		"--reverse"
		"${colors[@]}"
	)

	bssid=$(fzf "${opts[@]}" <<< "$networks" | awk '{print $1}')

	case $bssid in
		"") return 1 ;;
		"*")
			notify-send "Wi-Fi" "Already connected to this network" \
				-i "package-install"
			return 1
			;;
	esac
}

connect() {
	printf "Connecting...\n"

	if ! nmcli -a device wifi connect "$bssid"; then
		notify-send "Wi-Fi" "Failed to connect" -i "package-purge"
		return 1
	fi

	notify-send "Wi-Fi" "Successfully connected" -i "package-install"
}

main() {
	printf "\e[?25l"
	ensure-enabled || exit 1
	get-network-list || exit 1
	printf "\e[?25h"
	select-network || exit 1
	connect || exit 1
}

main
