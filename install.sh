#!/usr/bin/env bash

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
RESET="\e[39m"

DEPS=(
	"bluez"
	"bluez-utils" # bluetoothctl
	"brightnessctl"
	"fzf"
	"networkmanager" # nmcli
	"pacman-contrib" # checkupdates
	"pipewire-pulse"
	"otf-commit-mono-nerd"
)

main() {
	local errors=0

	printf "%bInstalling dependencies...%b\n" "$BLUE" "$RESET"

	local d
	for d in "${DEPS[@]}"; do
		if pacman -Qi "$d" > /dev/null; then
			printf "[%b/%b] %s\n" "$GREEN" "$RESET" "$d"
		else
			printf "[ ] %s...\n" "$d"

			if sudo pacman -S --noconfirm "$d"; then
				printf "[%b+%b] %s\n" "$GREEN" "$RESET" "$d"
			else
				printf "[%bx%b] %s\n" "$RED" "$RESET" "$d"
				((errors += 1))
			fi
		fi
	done

	printf "\n%bMaking scripts executable...%b\n" "$BLUE" "$RESET"
	chmod -v +x ~/.config/waybar/scripts/*.sh

	pkill waybar
	waybar &> /dev/null &
	disown

	if ((errors > 0)); then
		printf "\nInstallation completed with %b%d errors%b\n" \
			"$RED" "$errors" "$RESET"
	else
		printf "\n%bInstallation complete!%b\n" "$GREEN" "$RESET"
	fi
}

main
