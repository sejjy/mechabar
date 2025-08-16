#!/usr/bin/env bash
#
# Check for system updates using pacman and AUR helpers
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 16, 2025
# License: MIT

repo_updates=$(pacman -Quq | wc -l)

helper=$(
	basename "$(
		command -v yay trizen pikaur paru pakku pacaur aurman aura 2>/dev/null |
			head -n 1
	)"
)

if [[ -z $helper ]]; then
	helper="none"
	aur_updates=0
else
	aur_updates=$($helper -Quaq | wc -l)
fi

tooltip="Pacman: $repo_updates\nAUR ($helper): $aur_updates"

echo "{\"text\": \" \", \"tooltip\": \"$tooltip\"}"
