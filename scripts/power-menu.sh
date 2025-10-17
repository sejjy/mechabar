#!/usr/bin/env bash
#
# Launch power menu using fzf
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 19, 2025
# License: MIT

LIST=(
	Lock
	Shutdown
	Reboot
	Logout
	Hibernate
	Suspend
)

select-action() {
	# shellcheck disable=SC1090
	. ~/.config/waybar/scripts/theme-switcher.sh 'fzf' # get fzf colors

	local opts=("${COLORS[@]}")
	opts+=(
		--border=sharp
		--border-label=' Power Menu '
		--height=~100%
		--highlight-line
		--no-input
		--pointer=
		--reverse
	)

	action=$(printf '%s\n' "${LIST[@]}" | fzf "${opts[@]}")
}

main() {
	select-action

	case $action in
		'Lock') loginctl lock-session ;;
		'Shutdown') systemctl poweroff ;;
		'Reboot') systemctl reboot ;;
		'Logout') loginctl terminate-session "$XDG_SESSION_ID" ;;
		'Hibernate') systemctl hibernate ;;
		'Suspend') systemctl suspend ;;
	esac
}

main
