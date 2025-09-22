#!/usr/bin/env bash
#
# Install mechabar dependencies using pacman
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 22, 2025
# License: MIT

red='\033[1;31m'
green='\033[1;32m'
blue='\033[1;34m'
reset='\033[0m'

DEPS=(
	bluez
	bluez-utils # bluetoothctl
	brightnessctl
	fzf
	networkmanager # nmcli
	pipewire-pulse
	ttf-0xproto-nerd
)

install-deps() {
	local package
	local errors=0

	echo -e "${blue}Installing dependencies...${reset}" >&2

	for package in "${DEPS[@]}"; do
		if pacman -Qi "$package" &>/dev/null; then
			echo -e "[${green}/${reset}] $package" >&2
		else
			echo "[ ] $package..." >&2

			if sudo pacman -S --noconfirm "$package"; then
				echo -e "[${green}+${reset}] $package" >&2
			else
				echo -e "[${red}-${reset}] $package" >&2
				((errors++))
			fi
		fi
	done

	echo "$errors"
}

setup-scripts() {
	echo -e "\n${blue}Making scripts executable...${reset}"
	chmod +x ~/.config/waybar/scripts/*.sh
}

restart-waybar() {
	echo -e "\n${blue}Restarting Waybar...${reset}"

	pkill waybar 2>/dev/null || true
	nohup waybar >/dev/null 2>&1 &
}

display-result() {
	local errors=$1

	if ((errors > 0)); then
		echo -e "\nInstallation completed with ${red}$errors error(s)${reset}"
	else
		echo -e "\n${green}Installation complete!${reset}"
	fi
}

main() {
	local errors
	errors=$(install-deps)

	setup-scripts
	restart-waybar
	display-result "$errors"
}

main "$@"
