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

HELPER=$(command -v yay trizen pikaur paru pakku pacaur aurman aura |
	head -n 1 | xargs -- basename)

check-updates() {
	local repo
	local aur=0
	local s=5

	repo=$(timeout $s pacman -Quq | wc -l) || repo=0

	if [[ -n $HELPER ]]; then
		aur=$(timeout $s "$HELPER" -Quaq 2>/dev/null | wc -l) ||
			aur=0
	fi

	echo "$repo" "$aur"
}

update-packages() {
	local repo=$1
	local aur=$2

	if ((repo > 0)); then
		printf '\n\n'
		echo -e "${BLU}Updating pacman packages...${RST}"
		sudo pacman -Syu
	fi

	if ((aur > 0)); then
		echo -e "\n${BLU}Updating AUR packages...${RST}"
		"$HELPER" -Syu
	fi

	notify-send 'Update Complete' -i 'package-installed-updated'

	echo -e "\n${GRN}Update complete!${RST}\n"
	read -rs -n 1 -p 'Press any key to exit...'
}

display-tooltip() {
	local repo=$1
	local aur=$2
	local tooltip total

	tooltip="Official: $repo"

	if [[ -n $HELPER ]]; then
		tooltip+="\nAUR($HELPER): $aur"
	fi

	total=$((repo + aur))

	if ((total > 0)); then
		echo "{ \"text\": \"\", \"tooltip\": \"$tooltip\" }"
	else
		echo "{ \"text\": \"󰸟\", \"tooltip\": \"No updates available\" }"
	fi
}

main() {
	local action=$1
	local repo aur

	case $action in
		start)
			echo -en "${BLU}Checking for updates...${RST}"

			read -r repo aur < <(check-updates)
			update-packages "$repo" "$aur"
			;;
		*)
			read -r repo aur < <(check-updates)
			display-tooltip "$repo" "$aur"
			;;
	esac
}

main "$@"
