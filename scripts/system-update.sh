#!/usr/bin/env bash
#
# Check for official and AUR package updates and upgrade them. When run with the
# "module" argument, output the status icon and update counts in JSON format for
# Waybar
#
# Requirements:
# - notify-send (libnotify)
# - checkupdates (pacman-contrib) — only needed if no AUR helper is installed
# - AUR helper (optional) — aura, paru, pikaur, trizen, or yay
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 16, 2025
# License: MIT

set -o pipefail

FG_GREEN="\e[32m"
FG_BLUE="\e[34m"
FG_RESET="\e[39m"

FAILURE=false
PAC_UPD=0
AUR_UPD=0
HELPER=

TIMEOUT=10
HELPERS=(aura paru pikaur trizen yay)

printf() {
	command printf "$@" >&2
}

get_helper() {
	local helper
	for helper in "${HELPERS[@]}"; do
		if command -v "$helper" > /dev/null; then
			HELPER=$helper
			break
		fi
	done
}

reset_state() {
	FAILURE=false
	PAC_UPD=0
	AUR_UPD=0
}

get_ignored_pkgs() {
	grep -E "^IgnorePkg" /etc/pacman.conf | sed 's/IgnorePkg = //' | tr ' ' '\n' | grep -v '^$'
}

filter_ignored() {
	local ignored
	ignored=$(get_ignored_pkgs)
	if [[ -z $ignored ]]; then
		cat
	else
		grep -v -F -f <(echo "$ignored") || true
	fi
}

check_updates() {
	reset_state

	if [[ -n $HELPER ]]; then
		local pac_output pac_status
		pac_output=$(timeout $TIMEOUT "$HELPER" -Qud | filter_ignored)
		pac_status=$?

		if ((pac_status != 0 && pac_status != 2)); then
			FAILURE=true
			return 1
		fi
		PAC_UPD=$(grep -c . <<< "$pac_output")

		local aur_output aur_status
		aur_output=$(timeout $TIMEOUT "$HELPER" -Qua | filter_ignored)
		aur_status=$?

		if ((${#aur_output} > 0 && aur_status != 0)); then
			FAILURE=true
			return 1
		fi
		AUR_UPD=$(grep -c . <<< "$aur_output")
	else
		local pac_output pac_status
		pac_output=$(timeout $TIMEOUT checkupdates | filter_ignored)
		pac_status=$?

		if ((pac_status != 0 && pac_status != 2)); then
			FAILURE=true
			return 1
		fi
		PAC_UPD=$(grep -c . <<< "$pac_output")
		AUR_UPD=0
	fi
}

update_packages() {
	if [[ -n $HELPER ]]; then
		printf "%bUpdating packages ($HELPER)...%b\n" "$FG_BLUE" "$FG_RESET"
		command "$HELPER" -Syu
	else
		printf "%bUpdating packages (pacman)...%b\n" "$FG_BLUE" "$FG_RESET"
		sudo pacman -Syu
	fi

	notify-send "Update Complete" -i "package-install"

	printf "\n%bUpdate Complete!%b\n" "$FG_GREEN" "$FG_RESET"
	read -rsn 1 -p "Press any key to exit..."
}

display_module() {
	local icon tooltip

	if $FAILURE; then
		icon='󰒑'
		tooltip="Cannot fetch updates. Right-click to retry."
	elif ((PAC_UPD + AUR_UPD == 0)); then
		icon='󰸟'
		tooltip="No updates available"
	else
		icon='󰄠'
		tooltip="<b>Official</b>: $PAC_UPD"

		if [[ -n $HELPER ]]; then
			tooltip+="\n<b>AUR($HELPER)</b>: $AUR_UPD"
		fi
	fi

	command printf '{ "text": "%s", "tooltip": "%s" }\n' "$icon" "$tooltip"
}

main() {
	get_helper

	case $1 in
		module)
			check_updates
			display_module
			;;
		*)
			printf "%bChecking for updates...%b\n" "$FG_BLUE" "$FG_RESET"
			check_updates
			update_packages

			# update the module
			pkill -RTMIN+1 waybar
			;;
	esac
}

main "$@"
