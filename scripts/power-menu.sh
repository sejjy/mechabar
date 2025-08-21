#!/usr/bin/env bash

list=$(printf '%s\n' 'Lock' 'Shutdown' 'Reboot' 'Logout' 'Hibernate' 'Suspend')

# fzf options
options=(
	--border=sharp
	--border-label=' Power Menu '
	--height=~100%
	--highlight-line
	--no-input
	--pointer=
	--reverse
)

mechadir="$HOME/.config/waybar"
source "$mechadir/scripts/theme-switcher.sh" fzf

options+=("${colors[@]}")

selected=$(fzf "${options[@]}" <<<"$list")

[[ -z $selected ]] && exit 0

case "$selected" in
	'Lock')
		loginctl lock-session
		;;
	'Shutdown')
		systemctl poweroff
		;;
	'Reboot')
		systemctl reboot
		;;
	'Logout')
		loginctl terminate-session "$XDG_SESSION_ID"
		;;
	'Hibernate')
		systemctl hibernate
		;;
	'Suspend')
		systemctl suspend
		;;
esac
