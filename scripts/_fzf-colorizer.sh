#!/usr/bin/env bash
#
# A helper script that syncs fzf colors with the current Waybar theme

main() {
	local wcss=~/.config/waybar/current-theme.css
	local wtheme fcolors wcolors

	wtheme=$(sed 1q $wcss | awk '{print $2}')
	fcolors=~/.config/waybar/themes/fzf/$wtheme.txt
	# Extract theme colors starting from line 3 up to (but not including) the
	# first blank line
	wcolors=$(sed -n '3,${/^ *$/Q;p}' $wcss)

	local line element color hex
	fcconf=()
	while read -r line; do
		read -r element color <<< "$line"
		read -r _ _ hex < <(grep " $color " <<< "$wcolors")
		hex=${hex%;}
		fcconf+=("--color=$element:$hex")
	done < "$fcolors"
}

main
