#!/usr/bin/env bash
#
# Launch power menu using fzf
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 19, 2025
# License: MIT

# shellcheck disable=SC1091
source "$HOME/.config/waybar/scripts/theme-switcher.sh" fzf

LIST=(
	'Lock'
	'Shutdown'
	'Reboot'
	'Logout'
	'Hibernate'
	'Suspend'
)

select-action() {
	local opts=("${COLORS[@]}")
	local action

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

	if [[ -z $action ]]; then
		return 1
	else
		echo "$action"
	fi
}

main() {
	local action
	action=$(select-action) || exit 1

	case $action in
		'Lock') loginctl lock-session ;;
		'Shutdown') systemctl poweroff ;;
		'Reboot') systemctl reboot ;;
		'Logout') loginctl terminate-session "$XDG_SESSION_ID" ;;
		'Hibernate') systemctl hibernate ;;
		'Suspend') systemctl suspend ;;
	esac
}

main "$@"
