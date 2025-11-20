#!/usr/bin/env bash
#
# Check for available updates and optionally upgrade packages on Arch Linux.
#
# Requirements:
# 	- checkupdates (pacman-contrib)
# 	- notify-send (libnotify)
# 	- optional: an AUR helper (aura, paru, pikaur, trizen, yay)
#
# Author: Jesse Mirabel <sejjymvm@gmail.com>
# Created: August 16, 2025
# License: MIT

GRN='\033[1;32m'
BLU='\033[1;34m'
RST='\033[0m'

TIMEOUT=10

check-updates() {
	is_online=true

	local rout rstat
	rout=$(timeout $TIMEOUT checkupdates)
	rstat=$?
	# 2 means no updates are available
	if ((rstat != 0 && rstat != 2)); then
		is_online=false
		return 1
	fi
	repo=0
	repo=$(grep -cve '^\s*$' <<< "$rout")

	aur=0
	if [[ -n $helper ]]; then
		local aout astat
		aout=$(timeout $TIMEOUT "$helper" -Quaq)
		astat=$?
		# return only if the exit status is non-zero and there is an error
		# message
		if ((${#aout} > 0 && astat != 0)); then
			is_online=false
			return 1
		fi
		aur=$(grep -cve '^\s*$' <<< "$aout")
	fi
}

update-packages() {
	printf '\n%bUpdating pacman packages...%b\n' "$BLU" "$RST"
	sudo pacman -Syu

	printf '\n%bUpdating AUR packages...%b\n' "$BLU" "$RST"
	"$helper" -Syu

	notify-send 'Update Complete' -i 'package-install'
	printf '\n%bUpdate Complete!%b\n' "$GRN" "$RST"
	read -rs -n 1 -p 'Press any key to exit...'
}

display-module() {
	local tooltip
	if [[ $is_online == false ]]; then
		tooltip='Cannot fetch updates'
		tooltip+='\nRight-click to retry'
		echo "{ \"text\": \"󰒑\", \"tooltip\": \"$tooltip\" }"
		return
	fi

	tooltip="Official: $repo"
	if [[ -n $helper ]]; then
		tooltip+="\nAUR($helper): $aur"
	fi

	local total=$((repo + aur))
	if ((total == 0)); then
		echo "{ \"text\": \"󰸟\", \"tooltip\": \"No updates available\" }"
	else
		echo "{ \"text\": \"󰄠\", \"tooltip\": \"$tooltip\" }"
	fi
}

main() {
	local helpers=(aura paru pikaur trizen yay)
	local bin
	bin=$(command -v "${helpers[@]}" | head -n 1)
	helper=${bin##*/}

	case $1 in
		'module')
			check-updates
			display-module
			;;
		*)
			printf '%bChecking for updates...%b' "$BLU" "$RST"
			check-updates
			update-packages
			# use signal to update the module
			pkill -RTMIN+1 waybar
			;;
	esac
}

main "$@"
