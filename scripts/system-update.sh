#!/usr/bin/env bash
#
# Check for package updates using pacman and AUR helper
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 16, 2025
# License: MIT

green='\033[1;32m'
blue='\033[1;34m'
reset='\033[0m'

check_updates() {
	local s=5

	if ! repo_updates=$(timeout $s pacman -Quq | wc -l); then
		repo_updates=0
	fi

	helper=$(
		basename "$(command -v yay trizen pikaur paru pakku pacaur aurman aura |
			head -n 1)"
	)

	if [[ -n $helper ]]; then
		if ! aur_updates=$(timeout $s "$helper" -Quaq 2>/dev/null | wc -l); then
			aur_updates=0
		fi
	else
		aur_updates=0
	fi
}

update_packages() {
	if ((repo_updates > 0)); then
		printf '\n\n'
		echo -e "${blue}Updating pacman packages...${reset}"
		sudo pacman -Syu
	fi

	if ((aur_updates > 0)); then
		echo -e "\n${blue}Updating AUR packages...${reset}"
		"$helper" -Syu
	fi
}

if [[ $1 == 'start' ]]; then
	echo -en "${blue}Checking for updates...${reset}"

	check_updates
	update_packages

	notify-send 'Update Complete'
	echo -e "\n${green}Update complete!${reset}\n"

	read -rs -n 1 -p 'Press any key to exit...'
	exit 0
fi

check_updates

tooltip="Official: $repo_updates"

if [[ -n $helper ]]; then
	tooltip+="\nAUR($helper): $aur_updates"
fi

total_updates=$((repo_updates + aur_updates))

if ((total_updates > 0)); then
	echo "{ \"text\": \"\", \"tooltip\": \"$tooltip\" }"
else
	echo "{ \"text\": \"󰸟\", \"tooltip\": \"No updates available\" }"
fi
