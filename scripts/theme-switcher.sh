#!/usr/bin/env bash
#
# Switch waybar themes and export matching fzf colors
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 22, 2025
# License: MIT

THEMES=("$HOME/.config/waybar/themes/"*.css)
THEME_FILE=$HOME/.config/waybar/theme.css
CURRENT_THEME=$(head -n 1 "$THEME_FILE" | awk '{print $2}')

display-tooltip() {
	local theme_name

	theme_name=${CURRENT_THEME//-/ }
	theme_name="<span text_transform='capitalize'>$theme_name</span>"

	echo "{ \"text\": \">\", \"tooltip\": \"Theme: $theme_name\" }"
}

export-fzf-colors() {
	local rosewater mauve red lavender text overlay0 surface1 surface0 base

	case $CURRENT_THEME in
		catppuccin-frappe)
			rosewater='#f2d5cf'; mauve='#ca9ee6';    red='#e78284'
			lavender='#babbf1';  text='#c6d0f5';     overlay0='#737994'
			surface1='#51576d';  surface0='#414559'; base='#303446'
			;;
		catppuccin-latte)
			rosewater='#dc8a78'; mauve='#8839ef';    red='#d20f39'
			lavender='#7287fd';  text='#4c4f69';     overlay0='#9ca0b0'
			surface1='#bcc0cc';  surface0='#ccd0da'; base='#eff1f5'
			;;
		catppuccin-macchiato)
			rosewater='#f4dbd6'; mauve='#c6a0f6';    red='#ed8796'
			lavender='#b7bdf8';  text='#cad3f5';     overlay0='#6e738d'
			surface1='#494d64';  surface0='#363a4f'; base='#24273a'
			;;
		catppuccin-mocha)
			rosewater='#f5e0dc'; mauve='#cba6f7';    red='#f38ba8'
			lavender='#b4befe';  text='#cdd6f4';     overlay0='#6c7086'
			surface1='#45475a';  surface0='#313244'; base='#1e1e2e'
			;;
	esac

	export FZF_COLORS=(
		--color="bg+:$surface0,bg:$base,spinner:$rosewater,hl:$red"
		--color="fg:$text,header:$red,info:$mauve,pointer:$rosewater"
		--color="marker:$lavender,fg+:$text,prompt:$mauve,hl+:$red"
		--color="selected-bg:$surface1"
		--color="border:$overlay0,label:$text"
	)
}

switch-theme() {
	local action=$1
	local n theme new_index new_theme
	local index=-1

	for n in "${!THEMES[@]}"; do
		theme=$(basename "${THEMES[$n]}" .css)

		if [[ $theme == "$CURRENT_THEME" ]]; then
			index=$n
			break
		fi
	done

	case $action in
		next)
			new_index=$(((index + 1) % ${#THEMES[@]}))
			;;
		prev)
			new_index=$(((index - 1 + ${#THEMES[@]}) % ${#THEMES[@]}))
			;;
	esac

	new_theme="${THEMES[$new_index]}"
	cp "$new_theme" "$THEME_FILE"

	pkill waybar 2>/dev/null || true
	nohup waybar >/dev/null 2>&1 &
}

main() {
	local action=$1

	case $action in
		next | prev) switch-theme "$action" ;;
		fzf) export-fzf-colors ;;
		*) display-tooltip ;;
	esac
}

main "$@"
