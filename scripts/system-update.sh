#!/usr/bin/env bash
#
# Check for available updates and optionally upgrade packages on Arch Linux.
#
# Requirements:
# 	- checkupdates (pacman-contrib)
# 	- notify-send (libnotify)
# 	- optional: an AUR helper (aura, paru, pikaur, trizen, yay)
#
# Author: Jesse Mirabel <sejjymvm@gmail.com>
# Created: August 16, 2025
# License: MIT

GRN='\033[1;32m'
BLU='\033[1;34m'
RST='\033[0m'

TIMEOUT=5

check-updates() {
	repo=$(timeout $TIMEOUT checkupdates 2> /dev/null | wc -l)

	if [[ -n $helper ]]; then
		aur=$(timeout $TIMEOUT "$helper" -Quaq 2> /dev/null | wc -l)
	fi
}

update-packages() {
	printf '\n%bUpdating pacman packages...%b\n' "$BLU" "$RST"
	sudo pacman -Syu

	printf '\n%bUpdating AUR packages...%b\n' "$BLU" "$RST"
	"$helper" -Syu

	# use signal to update the module
	pkill -RTMIN+1 waybar

	notify-send 'Update Complete' -i 'package-install'
	printf '\n%bUpdate Complete!%b\n' "$GRN" "$RST"
	read -rs -n 1 -p 'Press any key to exit...'
}

display-module() {
	local tooltip="Official: $repo"

	if [[ -n $helper ]]; then
		tooltip+="\nAUR($helper): $aur"
	fi

	local total=$((repo + aur))

	if ((total == 0)); then
		echo "{ \"text\": \"󰸟\", \"tooltip\": \"No updates available\" }"
	else
		echo "{ \"text\": \"\", \"tooltip\": \"$tooltip\" }"
	fi
}

main() {
	local arg=$1
	local helpers=(aura paru pikaur trizen yay)
	local bin

	bin=$(command -v "${helpers[@]}" | head -n 1)
	helper=${bin##*/}
	repo=0
	aur=0

	case $arg in
		'module')
			check-updates
			display-module
			;;
		*)
			printf '%bChecking for updates...%b' "$BLU" "$RST"
			check-updates
			update-packages
			;;
	esac
}

main "$@"
