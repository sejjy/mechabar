#!/usr/bin/env bash

FG_RED="\e[31m"
FG_GREEN="\e[32m"
FG_BLUE="\e[34m"
FG_RESET="\e[39m"

ERRORS=0

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

printf() {
	command printf "$@" >&2
}

install_deps() {
	printf "%bInstalling dependencies...%b\n" "$FG_BLUE" "$FG_RESET"

	local dep
	for dep in "${DEPS[@]}"; do
		if pacman -Qi "$dep" > /dev/null; then
			printf "[/] %s\n" "$dep"
		else
			printf "[ ] %s...\n" "$dep"

			if sudo pacman -S --noconfirm "$dep"; then
				printf "%b[/] %s%b\n" "$FG_GREEN" "$dep" "$FG_RESET"
			else
				printf "%b[x] %s%b\n" "$FG_RED" "$dep" "$FG_RESET"
				((ERRORS += 1))
			fi
		fi
	done
}

restart_waybar() {
	printf "\n%bRestarting Waybar...%b\n" "$FG_BLUE" "$FG_RESET"

	if ! (systemctl --user is-enabled waybar.service &&
		systemctl --user restart waybar.service) &> /dev/null; then
		pkill waybar
		waybar &> /dev/null &
		disown
	fi
}

main() {
	install_deps
	restart_waybar

	if ((ERRORS > 0)); then
		printf "\n%bInstallation completed with %d error(s)%b\n" \
			"$FG_RED" "$ERRORS" "$FG_RESET"
	else
		printf "\n%bInstallation complete!%b\n" "$FG_GREEN" "$FG_RESET"
	fi
}

main
