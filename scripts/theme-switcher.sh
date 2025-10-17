#!/usr/bin/env bash
#
# Switch waybar themes and export matching fzf colors
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 22, 2025
# License: MIT

FILES=(~/.config/waybar/themes/*.css)
FILE=~/.config/waybar/theme.css
THEME=$(head -n 1 "$FILE" | awk '{print $2}')

switch-theme() {
	local i theme
	local index=-1

	for i in "${!FILES[@]}"; do
		theme=$(basename "${FILES[$i]}" .css)

		if [[ $theme == "$THEME" ]]; then
			index=$i
			break
		fi
	done

	local new_index
	case $action in
		'next') new_index=$(((index + 1) % ${#FILES[@]})) ;;
		'prev') new_index=$(((index - 1 + ${#FILES[@]}) % ${#FILES[@]})) ;;
	esac

	local new_theme=${FILES[$new_index]}
	cp "$new_theme" "$FILE"
}

export-colors() {
	local rosewater mauve red lavender text overlay0 surface1 surface0 base

	case $THEME in
		*'frappe')
			rosewater='#f2d5cf' mauve='#ca9ee6'    red='#e78284'
			lavender='#babbf1'  text='#c6d0f5'     overlay0='#737994'
			surface1='#51576d'  surface0='#414559' base='#303446'
			;;
		*'latte')
			rosewater='#dc8a78' mauve='#8839ef'    red='#d20f39'
			lavender='#7287fd'  text='#4c4f69'     overlay0='#9ca0b0'
			surface1='#bcc0cc'  surface0='#ccd0da' base='#eff1f5'
			;;
		*'macchiato')
			rosewater='#f4dbd6' mauve='#c6a0f6'    red='#ed8796'
			lavender='#b7bdf8'  text='#cad3f5'     overlay0='#6e738d'
			surface1='#494d64'  surface0='#363a4f' base='#24273a'
			;;
		*'mocha')
			rosewater='#f5e0dc' mauve='#cba6f7'    red='#f38ba8'
			lavender='#b4befe'  text='#cdd6f4'     overlay0='#6c7086'
			surface1='#45475a'  surface0='#313244' base='#1e1e2e'
			;;
	esac

	export COLORS=(
		--color="bg+:$surface0,bg:$base,spinner:$rosewater,hl:$red"
		--color="fg:$text,header:$red,info:$mauve,pointer:$rosewater"
		--color="marker:$lavender,fg+:$text,prompt:$mauve,hl+:$red"
		--color="selected-bg:$surface1"
		--color="border:$overlay0,label:$text"
	)
}

display-tooltip() {
	local name=$THEME
	name="<span text_transform='capitalize'>${name//-/ }</span>"

	echo "{ \"text\": \"󰍜\", \"tooltip\": \"Theme: $name\" }"
}

main() {
	local action=$1
	case $action in
		'next' | 'prev')
			switch-theme

			pkill waybar 2>/dev/null || true
			nohup waybar >/dev/null 2>&1 &
			;;
		fzf) export-colors ;;
		*) display-tooltip ;;
	esac
}

main "$@"
