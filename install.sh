#!/usr/bin/env bash

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

ERRORS=0

cprintf() {
	case $1 in
		red)   printf "\e[31m" ;;
		green) printf "\e[32m" ;;
		blue)  printf "\e[34m" ;;
	esac

	printf "%b%b\n" "${@:2}" "\e[39m" >&2
}

main() {
	cprintf blue "Installing dependencies..."

	local d
	for d in "${DEPS[@]}"; do
		if pacman -Qi "$d" > /dev/null; then
			cprintf green "[/] $d"
		else
			printf "[ ] %s...\n" "$d"

			if sudo pacman -S --noconfirm "$d"; then
				cprintf green "[+] $d"
			else
				cprintf red "[x] $d"
				((ERRORS += 1))
			fi
		fi
	done

	cprintf blue "\nMaking scripts executable..."
	chmod -v +x ~/.config/waybar/scripts/*.sh

	cprintf blue "\nRestarting Waybar..."

	pkill waybar
	waybar &> /dev/null &
	disown

	if ((ERRORS > 0)); then
		cprintf red "\nInstallation completed with $ERRORS errors"
	else
		cprintf green "\nInstallation complete!"
	fi
}

main
