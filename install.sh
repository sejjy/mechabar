#!/usr/bin/env bash

red='\033[1;31m'
green='\033[1;32m'
blue='\033[1;34m'
reset='\033[0m'

dependencies=(
	bluez
	bluez-utils # bluetoothctl
	brightnessctl
	fzf
	networkmanager # nmcli
	pipewire-pulse
	ttf-0xproto-nerd
)

install() {
	local package=$1

	if pacman -Qi "$package" &>/dev/null; then
		printf "[%b/%b] %s\n" "$green" "$reset" "$package"
	else
		printf "[ ] %s...\n" "$package"

		if sudo pacman -S --noconfirm "$package"; then
			printf "[%b+%b] %s\n" "$green" "$reset" "$package"
		else
			printf "[%b-%b] %s\n" "$red" "$reset" "$package"
			return 1
		fi
	fi
}

printf "%bInstalling dependencies...%b\n" "$blue" "$reset"

n=0
for package in "${dependencies[@]}"; do
	! install "$package" && ((n++))
done

printf "\n%bSetting up scripts...%b\n" "$blue" "$reset"
chmod +x ~/.config/waybar/scripts/*.sh

printf "\n%bRestarting Waybar...%b\n" "$blue" "$reset"
pkill waybar 2>/dev/null || true
nohup waybar >/dev/null 2>&1 &

if ((n > 0)); then
	printf "\nInstallation completed with %b%d error(s)%b\n" "$red" "$n" "$reset"
else
	printf "\n%bInstallation complete!%b\n" "$green" "$reset"
fi
