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

AUR_HELPER=$(command -v yay trizen pikaur paru pakku pacaur aurman aura |
	head -n 1 | xargs -- basename)

display-tooltip() {
	local repo_upd=$1
	local aur_upd=$2
	local tooltip total_upd

	tooltip="Official: $repo_upd"

	if [[ -n $AUR_HELPER ]]; then
		tooltip+="\nAUR($AUR_HELPER): $aur_upd"
	fi

	total_upd=$((repo_upd + aur_upd))

	if ((total_upd > 0)); then
		echo "{ \"text\": \"\", \"tooltip\": \"$tooltip\" }"
	else
		echo "{ \"text\": \"󰸟\", \"tooltip\": \"No updates available\" }"
	fi
}

update-packages() {
	local repo_upd=$1
	local aur_upd=$2

	if ((repo_upd > 0)); then
		printf '\n\n'
		echo -e "${blue}Updating pacman packages...${reset}"
		sudo pacman -Syu
	fi

	if ((aur_upd > 0)); then
		echo -e "\n${blue}Updating AUR packages...${reset}"
		"$AUR_HELPER" -Syu
	fi

	notify-send 'Update Complete' -i 'package-installed-updated'

	echo -e "\n${green}Update complete!${reset}\n"
	read -rs -n 1 -p 'Press any key to exit...'
}

check-updates() {
	local repo_upd
	local aur_upd=0
	local s=5

	repo_upd=$(timeout $s pacman -Quq | wc -l) || repo_upd=0

	if [[ -n $AUR_HELPER ]]; then
		aur_upd=$(timeout $s "$AUR_HELPER" -Quaq 2>/dev/null | wc -l) ||
			aur_upd=0
	fi

	echo "$repo_upd" "$aur_upd"
}

main() {
	local action=$1
	local repo_upd aur_upd

	case $action in
		start)
			echo -en "${blue}Checking for updates...${reset}"

			read -r repo_upd aur_upd < <(check-updates)
			update-packages "$repo_upd" "$aur_upd"
			;;
		*)
			read -r repo_upd aur_upd < <(check-updates)
			display-tooltip "$repo_upd" "$aur_upd"
			;;
	esac
}

main "$@"
