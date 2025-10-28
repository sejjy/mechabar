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
REPO=0
AUR=0

check-updates() {
	REPO=$(timeout $TIMEOUT checkupdates 2> /dev/null | wc -l)

	if [[ -n $helper ]]; then
		AUR=$(timeout $TIMEOUT "$helper" -Quaq 2> /dev/null | wc -l)
	fi
}

update-packages() {
	printf '\n%bUpdating pacman packages...%b\n' "$BLU" "$RST"
	sudo pacman -Syu

	printf '\n%bUpdating AUR packages...%b\n' "$BLU" "$RST"
	"$helper" -Syu

	notify-send 'Update Complete' -i 'package-install'

	printf '\n%bUpdate Complete!%b\n' "$GRN" "$RST"
	read -rs -n 1 -p 'Press any key to exit...'
}

display-module() {
	local tooltip="Official: $REPO"

	if [[ -n $helper ]]; then
		tooltip+="\nAUR($helper): $AUR"
	fi

	local total=$((REPO + AUR))

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
