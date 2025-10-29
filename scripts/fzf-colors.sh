#!/usr/bin/env bash
#
# NOTE:
# The names, maps, and COLORS arrays are all parallel:
# 	- names[i]: the color name as defined in theme.css
# 	- maps[i]:  variable to store the hex value
# 	- COLORS:   color config passed to fzf
#
# Add themes by defining the names array in def-colors().

FILE="$XDG_CONFIG_HOME/waybar/theme.css"

def-colors() {
	local theme
	theme=$(sed 1q "$FILE")

	declare -ga names

	# Add themes here:
	if [[ $theme == *"catppuccin"* ]]; then
		names=(
			'surface0' 'base'      'rosewater'
			'red'      'text'      'red'
			'mauve'    'rosewater' 'lavender'
			'text'     'mauve'     'red'
			'surface1' 'overlay0'  'text'
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
		'_cur_bg' '_bg'      '_spinner'
		'_hl'     '_fg'      '_header'
		'_info'   '_pointer' '_marker'
		'_cur_fg' '_prompt'  '_cur_hl'
		'_sel_bg' '_border'  '_label'
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

	# shellcheck disable=SC2154
	# These variables are defined dynamically
	declare -ga COLORS=(
		"--color=        bg+:$_cur_bg,      bg:$_bg,      spinner:$_spinner"
		"--color=         hl:$_hl,          fg:$_fg,       header:$_header"
		"--color=       info:$_info,   pointer:$_pointer,  marker:$_marker"
		"--color=        fg+:$_cur_fg,  prompt:$_prompt,      hl+:$_cur_hl"
		"--color=selected-bg:$_sel_bg,  border:$_border,    label:$_label"
	)

	export COLORS
}

main
