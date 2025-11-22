#!/usr/bin/env bash
#
# Sync fzf colors with the current Waybar theme

main() {
	local wcss=~/.config/waybar/theme.css
	local wtheme
	wtheme=$(sed 1q $wcss | awk '{print $2}')
	local fcolors=~/.config/waybar/themes/fzf/$wtheme.txt
	local wcolors
	wcolors=$(sed -n '3,28p' $wcss)

	local line element color hex
	while read -r line; do
		read -r element color <<< "$line"
		read -r _ _ hex < <(grep " $color " <<< "$wcolors")
		hex=${hex%;}
		declare "_$element=$hex"
	done < "$fcolors"

	# shellcheck disable=SC2034,SC2154
	# These variables are declared dynamically
	fcconf=(
		"--color= current-bg:$_current_bg"
		"--color=         bg:$_bg"
		"--color=    spinner:$_spinner"
		"--color=         hl:$_hl"
		"--color=         fg:$_fg"
		"--color=     header:$_header"
		"--color=       info:$_info"
		"--color=    pointer:$_pointer"
		"--color=     marker:$_marker"
		"--color= current-fg:$_current_fg"
		"--color=     prompt:$_prompt"
		"--color= current-hl:$_current_hl"
		"--color=selected-bg:$_selected_bg"
		"--color=     border:$_border"
		"--color=      label:$_label"
	)
}

main
