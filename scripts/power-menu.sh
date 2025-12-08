#!/usr/bin/env bash
#
# Launch a power menu
#
# Requirements:
# 	- fzf
#
# Author: Jesse Mirabel <sejjymvm@gmail.com>
# Created: August 19, 2025
# License: MIT

fcconf=()
# Get fzf color config
# shellcheck disable=SC1090,SC2154
. ~/.config/waybar/scripts/_fzf_colorizer.sh 2> /dev/null || true
# If the file is missing, fzf will fall back to its default colors

main() {
	local list=(
		'Lock'
		'Shutdown'
		'Reboot'
		'Logout'
		'Hibernate'
		'Suspend'
	)
	local opts=(
		'--border=sharp'
		'--border-label= Power Menu '
		'--height=~100%'
		'--highlight-line'
		'--no-input'
		'--pointer='
		'--reverse'
		"${fcconf[@]}"
	)

	local selected
	selected=$(printf '%s\n' "${list[@]}" | fzf "${opts[@]}")
	case $selected in
		'Lock') loginctl lock-session ;;
		'Shutdown') systemctl poweroff ;;
		'Reboot') systemctl reboot ;;
		'Logout') loginctl terminate-session "$XDG_SESSION_ID" ;;
		'Hibernate') systemctl hibernate ;;
		'Suspend') systemctl suspend ;;
		*) exit 1 ;;
	esac
}

main
