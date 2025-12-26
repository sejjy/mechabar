#!/usr/bin/env bash
# Syncs fzf colors with the current waybar theme

main() {
	local w_theme w_colors
	w_theme="$HOME/.config/waybar/current-theme.css"
	w_colors=$(sed -n '3,${/^ *$/Q;p}' "$w_theme")

	local w_theme_name f_theme
	w_theme_name=$(sed 1q "$w_theme" | awk '{print $2}')
	f_theme="$HOME/.config/waybar/themes/fzf/$w_theme_name.txt"

	local element name hex
	while read -r element name; do
		read -r _ _ hex < <(grep " $name " <<< "$w_colors")
		hex=${hex%;}
		colors+=("--color=$element:$hex")
	done < "$f_theme"
}

main
