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
	printf '%bInstalling dependencies...%b\n' "$BLU" "$RST"

	local pkg
	err=0

	for pkg in "${DEPS[@]}"; do
		if pacman -Qi "$pkg" &>/dev/null; then
			printf '[%b/%b] %s\n' "$GRN" "$RST" "$pkg"
		else
			printf '[ ] %s...\n' "$pkg"

			if sudo pacman -S --noconfirm "$pkg"; then
				printf '[%b+%b] %s\n' "$GRN" "$RST" "$pkg"
			else
				printf '[%bx%b] %s\n' "$RED" "$RST" "$pkg"
				((err++))
			fi
		fi
	done
}

setup-scripts() {
	printf '\n%bMaking scripts executable...%b\n' "$BLU" "$RST"

	chmod -v +x ~/.config/waybar/scripts/*.sh
}

display-result() {
	if ((err > 0)); then
		printf '\nInstallation completed with %b%d error(s)%b\n' \
			"$RED" "$err" "$RST"
	else
		printf '\n%bInstallation complete!%b\n' "$GRN" "$RST"
	fi
}

main() {
	install-deps
	setup-scripts

	pkill waybar 2>/dev/null || true
	nohup waybar >/dev/null 2>&1 &

	display-result
}

main
