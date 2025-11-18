#!/usr/bin/env bash

CSS=~/.config/waybar/theme.css
DEFS=$(sed -n '3,28p' $CSS)

get-hex() {
	read -r _ _ hex < <(grep " $1 " <<< "$DEFS")
	hex=${hex%;}
}

get-defs() {
	local theme
	theme=$(sed 1q $CSS | awk '{print $2}')
	local fzfconf=~/.config/waybar/themes/fzf/$theme.jsonc

	mapfile -t keys < <(jq -r ".\"$theme\" | keys_unsorted[]" "$fzfconf")
	mapfile -t values < <(jq -r ".\"$theme\"[]" "$fzfconf")
}

main() {
	get-defs

	local i key value
	for i in "${!keys[@]}"; do
		key=${keys[i]}
		value=${values[i]}

		get-hex "$value"
		declare "$key=$hex"
	done

	# shellcheck disable=SC2034,SC2154
	COLORS=(
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
