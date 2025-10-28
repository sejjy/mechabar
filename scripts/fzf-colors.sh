#!/usr/bin/env bash

FILE="$XDG_CONFIG_HOME/waybar/theme.css"

def-colors() {
	local theme
	theme=$(sed 1q "$FILE")

	declare -ga names

	# add themes here
	if [[ $theme == *"catppuccin"* ]]; then
		names=(
			'surface0' 'base' 'rosewater' 'red' 'text' 'red' 'mauve' 'rosewater'
			'lavender' 'text' 'mauve' 'red' 'surface1' 'overlay0' 'text'
		)
	fi
}

get-hex() {
	local defs
	defs=$(sed -n '3,28p' "$FILE")

	local n hex
	declare -gA colors

	for n in "${names[@]}"; do
		read -r _ _ hex < <(grep " $n " <<< "$defs")
		hex=${hex%;}

		colors[$n]=$hex
	done
}

map-colors() {
	local -a maps=(
		'bgp' 'bg' 'spinner' 'hl' 'fg' 'header' 'info' 'pointer' 'marker' 'fgp'
		'prompt' 'hlp' 'selected_bg' 'border' 'label'
	)

	local n
	local i=0

	for n in "${names[@]}"; do
		declare -g "${maps[i]}"="${colors[$n]}"
		((i++))
	done
}

main() {
	def-colors
	get-hex
	map-colors

	declare -ga COLORS=(
		"--color=bg+:${bgp:?},bg:${bg:?},spinner:${spinner:?},hl:${hl:?}"
		"--color=fg:${fg:?},header:${header:?},info:${info:?}"
		"--color=pointer:${pointer:?},marker:${marker:?},fg+:${fgp:?}"
		"--color=prompt:${prompt:?},hl+:${hlp:?},selected-bg:${selected_bg:?}"
		"--color=border:${border:?},label:${label:?}"
	)

	export COLORS
}

main
