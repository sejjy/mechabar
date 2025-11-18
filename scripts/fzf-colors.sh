#!/usr/bin/env bash

themefile=~/.config/waybar/theme.css
fzfconf=~/.config/waybar/themes/fzf_color_config.jsonc

theme=$(sed 1q $themefile | awk '{print $2}')
colordefs=$(sed -n '3,28p' $themefile)

mapfile -t keys < <(jq -r ".\"$theme\" | keys_unsorted[]" $fzfconf)
mapfile -t values < <(jq -r ".\"$theme\"[]" $fzfconf)

for i in "${!keys[@]}"; do
	key=${keys[i]}
	value=${values[i]}

	read -r _ _ hex < <(grep " $value " <<< "$colordefs")
	hex=${hex%;}

	declare "$key=$hex"
done

# shellcheck disable=SC2034
# shellcheck disable=SC2154
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
