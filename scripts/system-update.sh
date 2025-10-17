#!/usr/bin/env bash
#
# Update system packages using pacman and AUR helper
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 16, 2025
# License: MIT

GRN='\033[1;32m'
BLU='\033[1;34m'
RST='\033[0m'

TIMEOUT=5
HELPER=$(command -v yay trizen pikaur paru pakku pacaur aurman aura |
	head -n 1 | xargs -- basename)

check-updates() {
	repo=0
	repo=$(timeout $TIMEOUT pacman -Quq | wc -l)

	aur=0
	if [[ -n $HELPER ]]; then
		aur=$(timeout $TIMEOUT "$HELPER" -Quaq 2>/dev/null | wc -l)
	fi

	total=$((repo + aur))
}

update-packages() {
	if ((total == 0)); then
		notify-send 'No updates available' -i 'package-installed-updated'
	else
		if ((repo > 0)); then
			printf '\n%bUpdating pacman packages...%b\n' "$BLU" "$RST"
			sudo pacman -Syu
		fi

		if ((aur > 0)); then
			printf '\n%bUpdating AUR packages...%b\n' "$BLU" "$RST"
			"$HELPER" -Syu
		fi

		notify-send 'Update Complete' -i 'package-install'

		printf '\n%bUpdate Complete!%b\n' "$GRN" "$RST"
		read -rs -n 1 -p 'Press any key to exit...'
	fi
}

display-tooltip() {
	local tooltip="Official: $repo"

	if [[ -n $HELPER ]]; then
		tooltip+="\nAUR($HELPER): $aur"
	fi

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
