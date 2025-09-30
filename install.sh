#!/usr/bin/env bash
#
# Install mechabar dependencies using pacman
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 22, 2025
# License: MIT

RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
RST='\033[0m'

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

	echo -e "${BLU}Installing dependencies...${RST}" >&2

	for package in "${DEPS[@]}"; do
		if pacman -Qi "$package" &>/dev/null; then
			echo -e "[${GRN}/${RST}] $package" >&2
		else
			echo "[ ] $package..." >&2

			if sudo pacman -S --noconfirm "$package"; then
				echo -e "[${GRN}+${RST}] $package" >&2
			else
				echo -e "[${RED}-${RST}] $package" >&2
				((errors++))
			fi
		fi
	done

	echo "$errors"
}

setup-scripts() {
	echo -e "\n${BLU}Making scripts executable...${RST}"
	chmod +x ~/.config/waybar/scripts/*.sh
}

restart-waybar() {
	echo -e "\n${BLU}Restarting Waybar...${RST}"

	pkill waybar 2>/dev/null || true
	nohup waybar >/dev/null 2>&1 &
}

display-result() {
	local errors=$1

	if ((errors > 0)); then
		echo -e "\nInstallation completed with ${RED}$errors error(s)${RST}"
	else
		echo -e "\n${GRN}Installation complete!${RST}"
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
