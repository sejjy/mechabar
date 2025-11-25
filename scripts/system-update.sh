#!/usr/bin/env bash
#
# Check for official and AUR package updates and upgrade them. When run with the
# 'module' argument, output the status icon and update counts in JSON format for
# Waybar
#
# Requirements:
# 	- checkupdates (pacman-contrib)
# 	- notify-send (libnotify)
# 	- optional: an AUR helper
#
# Author: Jesse Mirabel <sejjymvm@gmail.com>
# Created: August 16, 2025
# License: MIT

GRN='\033[1;32m'
BLU='\033[1;34m'
RST='\033[0m'

TIMEOUT=10
HELPERS=('aura' 'paru' 'pikaur' 'trizen' 'yay')

detect-helper() {
	local h
	for h in "${HELPERS[@]}"; do
		if command -v "$h" > /dev/null; then
			helper=$h
			break
		fi
	done
}

check-updates() {
	is_online=true
	repo=0
	aur=0

	local rout rstat
	rout=$(timeout $TIMEOUT checkupdates)
	rstat=$?
	# 2 means no updates are available
	if ((rstat != 0 && rstat != 2)); then
		is_online=false
		return 1
	fi
	repo=$(grep -cve '^\s*$' <<< "$rout")

	if [[ -z $helper ]]; then
		return 0
	fi

	local aout astat
	aout=$(timeout $TIMEOUT "$helper" -Quaq)
	astat=$?
	# Return only if the exit status is non-zero and there is an error
	# message
	if ((${#aout} > 0 && astat != 0)); then
		is_online=false
		return 1
	fi
	aur=$(grep -cve '^\s*$' <<< "$aout")
}

update-packages() {
	printf '\n%bUpdating pacman packages...%b\n' "$BLU" "$RST"
	sudo pacman -Syu

	if [[ -n $helper ]]; then
		printf '\n%bUpdating AUR packages...%b\n' "$BLU" "$RST"
		"$helper" -Syu
	fi

	notify-send 'Update Complete' -i 'package-install'
	printf '\n%bUpdate Complete!%b\n' "$GRN" "$RST"
	read -rs -n 1 -p 'Press any key to exit...'
}

display-module() {
	if [[ $is_online == false ]]; then
		echo "{ \"text\": \"󰒑\", \"tooltip\": \"Cannot fetch updates. Right-click to retry.\" }"
		return 0
	fi

	local tooltip="<b>Official</b>: $repo"
	if [[ -n $helper ]]; then
		tooltip+="\n<b>AUR($helper)</b>: $aur"
	fi

	local total=$((repo + aur))
	if ((total == 0)); then
		echo "{ \"text\": \"󰸟\", \"tooltip\": \"No updates available\" }"
	else
		echo "{ \"text\": \"󰄠\", \"tooltip\": \"$tooltip\" }"
	fi
}

main() {
	detect-helper

	case $1 in
		'module')
			check-updates
			display-module
			;;
		*)
			printf '%bChecking for updates...%b' "$BLU" "$RST"
			check-updates
			update-packages
			# use signal to update the module
			pkill -RTMIN+1 waybar
			;;
	esac
}

main "$@"
