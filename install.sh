#!/usr/bin/env bash

DEPS=(
	bluez
	bluez-utils    # bluetoothctl
	brightnessctl
	fzf
	networkmanager # nmcli
	pacman-contrib # checkupdates
	pipewire-pulse
	otf-commit-mono-nerd
)

printf() {
	command printf "$@" >&2
}

cprintf() {
	case $1 in
		r) printf "\e[31m" ;;
		g) printf "\e[32m" ;;
		b) printf "\e[34m" ;;
	esac
	printf "%b" "${@:2}"
	printf "\e[39m\n"
}

main() {
	cprintf b "Installing dependencies..."

	local errors=0
	local d

	for d in "${DEPS[@]}"; do
		if pacman -Qi "$d" > /dev/null; then
			printf "[/] %s\n" "$d"
		else
			printf "[ ] %s...\n" "$d"

			if sudo pacman -S --noconfirm "$d"; then
				cprintf g "[+] $d"
			else
				cprintf r "[x] $d"
				((errors += 1))
			fi
		fi
	done

	cprintf b "\nMaking scripts executable..."
	chmod -v +x ~/.config/waybar/scripts/*.sh

	cprintf b "\nRestarting Waybar..."

	if ! (systemctl --user is-enabled waybar.service &&
		systemctl --user restart waybar.service) &> /dev/null; then
		pkill waybar
		waybar &> /dev/null &
		disown
	fi

	if ((errors > 0)); then
		cprintf r "\nInstallation completed with $errors errors"
	else
		cprintf g "\nInstallation complete!"
	fi
}

main
