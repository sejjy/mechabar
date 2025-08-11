#!/usr/bin/env bash

status=$(nmcli radio wifi)

if [[ $status == "disabled" ]]; then
	nmcli radio wifi on
	notify-send "Wi-Fi" "Enabled"
fi

echo "Scanning for networks..."

for _ in {1..10}; do
	output=$(nmcli device wifi list)
	header=$(head -n 1 <<<"$output")
	list=$(tail -n +2 <<<"$output")

	# networks found
	[[ -n "$list" ]] && break

	nmcli device wifi rescan &>/dev/null
	sleep 1
done

if [[ -z "$list" ]]; then
	notify-send "Wi-Fi" "No networks found" --urgency=critical
	exit 1
fi

# fzf config
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

# catppuccin mocha
# https://github.com/catppuccin/fzf
colors=(
	--color="bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8"
	--color="fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC"
	--color="marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8"
	--color="selected-bg:#45475A"
	--color="border:#6C7086,label:#CDD6F4"
)

options+=("${colors[@]}")

# selected network
bssid=$(fzf "${options[@]}" <<<"$list" | awk '{print $1}')

[[ -z "$bssid" ]] && exit 0

if [[ $bssid == "*" ]]; then
	notify-send "Wi-Fi" "Already connected to this network"
	exit 0
fi

echo "Connecting..."

if nmcli device wifi connect "$bssid" --ask; then
	notify-send "Wi-Fi" "Successfully connected"
else
	notify-send "Wi-Fi" "Connection failed" --urgency=critical
fi
