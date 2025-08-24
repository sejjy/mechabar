#!/usr/bin/env bash

mechadir="$HOME/.config/waybar"
theme_css="$mechadir/theme.css"

current_theme=$(head -n 1 "$theme_css" | awk '{print $2}')

if [[ $1 == 'next' || $1 == 'prev' ]]; then
	themes=("$mechadir/themes/"*.css)
	index=-1

	for i in "${!themes[@]}"; do
		theme=$(basename "${themes[$i]}" .css)

		if [[ $theme == "$current_theme" ]]; then
			index=$i
			break
		fi
	done

	if [[ $1 == 'next' ]]; then
		new_index=$(((index + 1) % ${#themes[@]}))
	else # prev
		new_index=$(((index - 1 + ${#themes[@]}) % ${#themes[@]}))
	fi

	new_theme="${themes[$new_index]}"
	cp "$new_theme" "$theme_css"

	pkill waybar 2>/dev/null || true
	nohup waybar >/dev/null 2>&1 &
fi

if [[ $1 == 'fzf' ]]; then
	if [[ $current_theme == 'catppuccin-frappe' ]]; then
		export colors=(
			--color='bg+:#414559,bg:#303446,spinner:#F2D5CF,hl:#E78284'
			--color='fg:#C6D0F5,header:#E78284,info:#CA9EE6,pointer:#F2D5CF'
			--color='marker:#BABBF1,fg+:#C6D0F5,prompt:#CA9EE6,hl+:#E78284'
			--color='selected-bg:#51576D'
			--color='border:#737994,label:#C6D0F5'
		)
	elif [[ $current_theme == 'catppuccin-latte' ]]; then
		export colors=(
			--color='bg+:#CCD0DA,bg:#EFF1F5,spinner:#DC8A78,hl:#D20F39'
			--color='fg:#4C4F69,header:#D20F39,info:#8839EF,pointer:#DC8A78'
			--color='marker:#7287FD,fg+:#4C4F69,prompt:#8839EF,hl+:#D20F39'
			--color='selected-bg:#BCC0CC'
			--color='border:#9CA0B0,label:#4C4F69'
		)
	elif [[ $current_theme == 'catppuccin-macchiato' ]]; then
		export colors=(
			--color='bg+:#363A4F,bg:#24273A,spinner:#F4DBD6,hl:#ED8796'
			--color='fg:#CAD3F5,header:#ED8796,info:#C6A0F6,pointer:#F4DBD6'
			--color='marker:#B7BDF8,fg+:#CAD3F5,prompt:#C6A0F6,hl+:#ED8796'
			--color='selected-bg:#494D64'
			--color='border:#6E738D,label:#CAD3F5'
		)
	elif [[ $current_theme == 'catppuccin-mocha' ]]; then
		export colors=(
			--color='bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8'
			--color='fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC'
			--color='marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8'
			--color='selected-bg:#45475A'
			--color='border:#6C7086,label:#CDD6F4'
		)
	fi

	return 0
fi

echo "{\"text\": \"󰏘\", \"tooltip\": \"Theme: $current_theme\"}"
