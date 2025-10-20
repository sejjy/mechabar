#!/usr/bin/env bash
#
# Checks for pending updates using checkupdates and upgrades packages using
# pacman and an AUR helper if available.
#
# Dependencies:
#  - checkupdates (from pacman-contrib)
#  - An AUR helper (optional)
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 16, 2025
# License: MIT

GRN='\033[1;32m'
BLU='\033[1;34m'
RST='\033[0m'

TIMEOUT=5
HELPER=$(command -v yay trizen pikaur paru pakku pacaur aurman aura | head -n 1)
HELPER=${HELPER##*/}

check-updates() {
	repo=0
	repo=$(timeout $TIMEOUT checkupdates 2>/dev/null | wc -l)

	# This might remain 0 until update-packages is run.
	aur=0
	if [[ -n $HELPER ]]; then
		aur=$(timeout $TIMEOUT "$HELPER" -Quaq 2>/dev/null | wc -l)
	fi
}

update-packages() {
	printf '\n%bUpdating pacman packages...%b\n' "$BLU" "$RST"
	sudo pacman -Syu

	printf '\n%bUpdating AUR packages...%b\n' "$BLU" "$RST"
	"$HELPER" -Syu

	notify-send 'Update Complete' -i 'package-install'

	printf '\n%bUpdate Complete!%b\n' "$GRN" "$RST"
	read -rs -n 1 -p 'Press any key to exit...'
}

display-tooltip() {
	local tooltip="Official: $repo"

	if [[ -n $HELPER ]]; then
		tooltip+="\nAUR($HELPER): $aur"
	fi

	local total=$((repo + aur))

	if ((total == 0)); then
		echo "{ \"text\": \"󰸟\", \"tooltip\": \"No updates available\" }"
	else
		echo "{ \"text\": \"\", \"tooltip\": \"$tooltip\" }"
	fi
}

main() {
	local action=$1
	case $action in
		'start')
			printf '%bChecking for updates...%b' "$BLU" "$RST"
			check-updates
			update-packages
			;;
		*)
			check-updates
			display-tooltip
			;;
	esac
}

main "$@"
