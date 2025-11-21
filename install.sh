#!/usr/bin/env bash

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
	pacman-contrib # checkupdates
	pipewire-pulse
	otf-commit-mono-nerd
)

main() {
	printf '%bInstalling dependencies...%b\n' "$BLU" "$RST"

	local package
	local error=0
	for package in "${DEPS[@]}"; do
		if pacman -Qi "$package" > /dev/null; then
			printf '[%b/%b] %s\n' "$GRN" "$RST" "$package"
		else
			printf '[ ] %s...\n' "$package"
			if sudo pacman -S --noconfirm "$package"; then
				printf '[%b+%b] %s\n' "$GRN" "$RST" "$package"
			else
				printf '[%bx%b] %s\n' "$RED" "$RST" "$package"
				((error++))
			fi
		fi
	done

	printf '\n%bMaking scripts executable...%b\n' "$BLU" "$RST"
	chmod +x ~/.config/waybar/scripts/*.sh --verbose

	pkill waybar
	waybar &> /dev/null &
	disown

	if ((error > 0)); then
		printf '\nInstallation completed with %b%d errors%b\n' \
			"$RED" "$error" "$RST"
	else
		printf '\n%bInstallation complete!%b\n' "$GRN" "$RST"
	fi
}

main
