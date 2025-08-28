#!/usr/bin/env bash

theme_css="$HOME/.config/waybar/theme.css"
theme_dir="$HOME/.config/waybar/themes"

current_theme=$(head -n 1 "$theme_css" | awk '{print $2}')

case $1 in
	'next' | 'prev')
		themes=("$theme_dir/"*.css)
		index=-1

		for i in "${!themes[@]}"; do
			theme=$(basename "${themes[$i]}" .css)

			if [[ $theme == "$current_theme" ]]; then
				index=$i
				break
			fi
		done

		case $1 in
			'next')
				new_index=$(((index + 1) % ${#themes[@]}))
				;;
			'prev')
				new_index=$(((index - 1 + ${#themes[@]}) % ${#themes[@]}))
				;;
		esac

		new_theme="${themes[$new_index]}"
		cp "$new_theme" "$theme_css"

		pkill waybar 2>/dev/null || true
		nohup waybar >/dev/null 2>&1 &
		;;

	'fzf')
		case $current_theme in
			'catppuccin-frappe')
				export colors=(
					--color='bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284'
					--color='fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf'
					--color='marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284'
					--color='selected-bg:#51576d'
					--color='border:#737994,label:#c6d0f5'
				)
				;;
			'catppuccin-latte')
				export colors=(
					--color='bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39'
					--color='fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78'
					--color='marker:#7287fd,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39'
					--color='selected-bg:#bcc0cc'
					--color='border:#9ca0b0,label:#4c4f69'
				)
				;;
			'catppuccin-macchiato')
				export colors=(
					--color='bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796'
					--color='fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6'
					--color='marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796'
					--color='selected-bg:#494d64'
					--color='border:#6e738d,label:#cad3f5'
				)
				;;
			'catppuccin-mocha')
				export colors=(
					--color='bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8'
					--color='fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc'
					--color='marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
					--color='selected-bg:#45475a'
					--color='border:#6c7086,label:#cdd6f4'
				)
				;;
		esac

		return 0
		;;
esac

tooltip=$(tr '-' ' ' <<<"$current_theme")

echo "{ \"text\": \">\", \"tooltip\": \"Theme: <span text_transform='capitalize'>${tooltip}</span>\" }"
