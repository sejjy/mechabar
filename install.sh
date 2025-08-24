#!/usr/bin/env bash

red='\033[1;31m'
green='\033[1;32m'
blue='\033[1;34m'
reset='\033[0m'

install() {
	if pacman -Qi "$1" &>/dev/null; then
		echo -e "[${green}/${reset}] $1"
		return 0
	else
		echo -e "[ ] $1..."
		if sudo pacman -S --noconfirm "$1"; then
			echo -e "[${green}+${reset}] $1"
			return 0
		else
			echo -e "[${red}x${reset}] $1" >&2
			return 1
		fi
	fi
}

echo -e "\n${blue}Installing dependencies...${reset}"
dependencies=(
	bluez bluez-utils brightnessctl fzf pipewire ttf-0xproto-nerd wireplumber
)

n=0
for package in "${dependencies[@]}"; do
	if ! install "$package"; then
		((n++))
	fi
done

echo -e "\n${blue}Setting up scripts...${reset}"
chmod +x scripts/*.sh

echo -e "\n${blue}Restarting Waybar...${reset}"
pkill waybar 2>/dev/null || true
nohup waybar >/dev/null 2>&1 &

if ((n > 0)); then
	echo -e "\nInstallation completed with ${red}${n} error/s${reset}"
else
	echo -e "\n${green}Installation complete!${reset}"
fi
