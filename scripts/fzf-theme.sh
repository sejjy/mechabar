#!/usr/bin/env bash
#
# A helper script that syncs fzf colors with the current Waybar theme

main() {
	local thm="$HOME/.config/waybar/current-theme.css"
	local thm_name; thm_name=$(sed 1q "$thm" | awk '{print $2}')
	local ff_thm="$HOME/.config/waybar/themes/fzf/$thm_name.txt"

	# Extract theme colors starting from line 3 up to (but not including) the
	# first blank line
	local dfn; dfn=$(sed -n '3,${/^ *$/Q;p}' "$thm")

	local e c hex
	while read -r e c; do
		read -r _ _ hex < <(grep " $c " <<< "$dfn")
		hex=${hex%;}
		colors+=("--color=$e:$hex")
	done < "$ff_thm"
}

main
