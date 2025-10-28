#!/usr/bin/env bash
#
# Display a power menu to perform system actions
#
# Requirements:
# 	- fzf
#
# Author: Jesse Mirabel <sejjymvm@gmail.com>
# Created: August 19, 2025
# License: MIT

LIST=(
	'Lock'
	'Shutdown'
	'Reboot'
	'Logout'
	'Hibernate'
	'Suspend'
)

main() {
	# shellcheck disable=SC1090
	. ~/.config/waybar/scripts/fzf-colors.sh 2> /dev/null

	local opts=(
		--border=sharp
		--border-label=' Power Menu '
		--height=~100%
		--highlight-line
		--no-input
		--pointer=
		--reverse
		"${COLORS[@]}"
	)

	local selected
	selected=$(printf '%s\n' "${LIST[@]}" | fzf "${opts[@]}")

	case $selected in
		'Lock') loginctl lock-session ;;
		'Shutdown') systemctl poweroff ;;
		'Reboot') systemctl reboot ;;
		'Logout') loginctl terminate-session "$XDG_SESSION_ID" ;;
		'Hibernate') systemctl hibernate ;;
		'Suspend') systemctl suspend ;;
	esac
}

main
