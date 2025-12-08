#!/usr/bin/env bash
#
# A helper script that syncs fzf colors with the current Waybar theme
#

main() {
	local wcss="$HOME/.config/waybar/current-theme.css"

	local wtheme fcolors
	wtheme=$(sed 1q "$wcss" | awk '{print $2}')
	fcolors="$HOME/.config/waybar/themes/fzf/$wtheme.txt"

	# Extract theme colors starting from line 3 up to (but not including) the
	# first blank line
	local wcolors
	wcolors=$(sed -n '3,${/^ *$/Q;p}' "$wcss")

	local element color hex
	fcconf=()
	while read -r element color; do
		read -r _ _ hex < <(grep " $color " <<< "$wcolors")
		hex=${hex%;}
		fcconf+=("--color=$element:$hex")
	done < "$fcolors"
}

main
