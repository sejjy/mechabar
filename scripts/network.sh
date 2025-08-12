#!/usr/bin/env bash

# connect to a Wi-Fi network using nmcli and fzf
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 11, 2025
# License: MIT

status=$(nmcli radio wifi)

if [[ $status == "disabled" ]]; then
	nmcli radio wifi on
	notify-send "Wi-Fi" "Enabled"
fi

echo -n "Retrieving networks..."

for i in {1..5}; do
	output=$(nmcli device wifi list)
	list=$(tail -n +2 <<<"$output")

	# networks found
	[[ -n "$list" ]] && break

	((i < 5)) && echo -en "\nScanning for networks... ($i/5)"
	nmcli device wifi rescan 2>/dev/null
	sleep 1
done

if [[ -z "$list" ]]; then
	notify-send "Wi-Fi" "No networks found"
	exit 1
fi

header=$(head -n 1 <<<"$output")

# fzf options
options=(
	--border=sharp
	--border-label=" Wi-Fi Networks "
	--ghost="Search"
	--header="$header"
	--highlight-line
	--info=inline-right
	--pointer=
	--reverse
)

# fzf theme (catppuccin mocha)
# source: https://github.com/catppuccin/fzf
colors=(
	--color="bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8"
	--color="fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC"
	--color="marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8"
	--color="selected-bg:#45475A"
	--color="border:#6C7086,label:#CDD6F4"
)

options+=("${colors[@]}")

# extract the BSSID of the selected network
bssid=$(fzf "${options[@]}" <<<"$list" | awk '{print $1}')

[[ -z "$bssid" ]] && exit 0

if [[ $bssid == "*" ]]; then
	notify-send "Wi-Fi" "Already connected to this network"
	exit 0
fi

echo -en "\nConnecting..."

if nmcli device wifi connect "$bssid" --ask; then
	notify-send "Wi-Fi" "Successfully connected"
else
	notify-send "Wi-Fi" "Connection failed"
fi
