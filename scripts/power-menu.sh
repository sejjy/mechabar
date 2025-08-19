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

# fzf theme (catppuccin mocha)
# source: https://github.com/catppuccin/fzf
colors=(
	--color='bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8'
	--color='fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC'
	--color='marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8'
	--color='selected-bg:#45475A'
	--color='border:#6C7086,label:#CDD6F4'
)

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
