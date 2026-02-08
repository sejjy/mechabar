#!/usr/bin/env bash
#
# Check for official and AUR package updates and upgrade them. When run with the
# "module" argument, output the status icon and update counts in JSON format for
# Waybar
#
# Requirements:
# - checkupdates (pacman-contrib)
# - notify-send (libnotify)
# - Optional: An AUR helper
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 16, 2025
# License: MIT

TIMEOUT=10
HELPERS=(aura paru pikaur trizen yay)

printf() {
	command printf "$@" >&2
}

cprintf() {
	case $1 in
		g) printf "\e[32m" ;;
		b) printf "\e[34m" ;;
	esac
	printf "%b" "${@:2}"
	printf "\e[39m\n"
}

get_helper() {
	local h
	for h in "${HELPERS[@]}"; do
		if command -v "$h" > /dev/null; then
			HELPER=$h
			break
		fi
	done
}

check_updates() {
	local pac_output pac_status

	pac_output=$(timeout $TIMEOUT checkupdates)
	pac_status=$?

	if ((pac_status != 0 && pac_status != 2)); then
		FAILURE=true
		return 1
	fi

	PAC_UPD=$(grep -cve "^\s*$" <<< "$pac_output")

	if [[ -z $HELPER ]]; then
		return 0
	fi

	local aur_output aur_status

	aur_output=$(timeout $TIMEOUT "$HELPER" -Quaq)
	aur_status=$?

	if ((${#aur_output} > 0 && aur_status != 0)); then
		FAILURE=true
		return 1
	fi

	AUR_UPD=$(grep -cve "^\s*$" <<< "$aur_output")
}

update_packages() {
	cprintf b "Updating pacman packages..."
	sudo pacman -Syu

	if [[ -n $HELPER ]]; then
		cprintf b "\nUpdating AUR packages..."
		command "$HELPER" -Syu
	fi

	notify-send "Update Complete" -i "package-install"

	cprintf g "\nUpdate Complete!"
	read -rsn 1 -p "Press any key to exit..."
}

display_module() {
	if $FAILURE; then
		command printf "{ \"text\": \"󰒑\", \"tooltip\": \"Cannot fetch updates. Right-click to retry.\" }\n"
		exit 0
	fi

	local tooltip="<b>Official</b>: $PAC_UPD"

	if [[ -n $HELPER ]]; then
		tooltip+="\n<b>AUR($HELPER)</b>: $AUR_UPD"
	fi

	if ((PAC_UPD + AUR_UPD == 0)); then
		command printf "{ \"text\": \"󰸟\", \"tooltip\": \"No updates available\" }\n"
	else
		command printf "{ \"text\": \"󰄠\", \"tooltip\": \"%s\" }\n" "$tooltip"
	fi
}

main() {
	get_helper

	FAILURE=false
	PAC_UPD=0
	AUR_UPD=0

	case $1 in
		module)
			check_updates
			display_module
			;;
		*)
			cprintf b "Checking for updates..."
			check_updates
			update_packages

			pkill -RTMIN+1 waybar
			;;
	esac
}

main "$@"
