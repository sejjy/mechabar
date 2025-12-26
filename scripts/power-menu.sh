#!/usr/bin/env bash
#
# Launch a power menu
#
# Requirement: fzf
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 19, 2025
# License: MIT

# shellcheck disable=SC1090
colors=()
source ~/.config/waybar/scripts/fzf-colorizer.sh &> /dev/null || true

main() {
	local list=(
		"Lock"
		"Shutdown"
		"Reboot"
		"Logout"
		"Hibernate"
		"Suspend"
	)

	local options=(
		"--border=sharp"
		"--border-label= Power Menu "
		"--height=~100%"
		"--highlight-line"
		"--no-input"
		"--pointer="
		"--reverse"
		"${colors[@]}"
	)

	local selected
	selected=$(printf "%s\n" "${list[@]}" | fzf "${options[@]}")

	case $selected in
		"Lock") loginctl lock-session ;;
		"Shutdown") systemctl poweroff ;;
		"Reboot") systemctl reboot ;;
		"Logout") loginctl terminate-session "$XDG_SESSION_ID" ;;
		"Hibernate") systemctl hibernate ;;
		"Suspend") systemctl suspend ;;
		*) exit 1 ;;
	esac
}

main
