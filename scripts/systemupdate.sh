#!/usr/bin/env bash

# Check release
if [ ! -f /etc/arch-release ]; then
  exit 0
fi

pkg_installed() {
  local pkg=$1
  if pacman -Qi "${pkg}" &>/dev/null; then
    return 0
  elif pacman -Qi "flatpak" &>/dev/null && flatpak info "${pkg}" &>/dev/null; then
    return 0
  elif command -v "${pkg}" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

get_aur_helper() {
  if pkg_installed yay; then
    aur_helper="yay"
  elif pkg_installed paru; then
    aur_helper="paru"
  fi
}

get_aur_helper
export -f pkg_installed
flatpak_update_cmd="pkg_installed flatpak && flatpak update"

# Trigger upgrade
if [ "$1" == "up" ]; then
  trap 'pkill -RTMIN+20 waybar' EXIT
  command="
    $0 upgrade
    ${aur_helper} -Syu
    $flatpak_update_cmd
    printf '\n'
    read -n 1 -p 'Press any key to continue...'
    "
  kitty --title "󰞒  System Update" sh -c "${command}"
fi

# Check for AUR updates
aur_updates=$(${aur_helper} -Qua | wc -l)
official_updates=$(
  (while pgrep -x checkupdates >/dev/null; do sleep 1; done)
  checkupdates | wc -l
)

# Check for Flatpak updates
if pkg_installed flatpak; then
  flatpak_updates=$(flatpak remote-ls --updates | wc -l)
else
  flatpak_updates=0
fi

# Calculate total available updates
total_updates=$((official_updates + aur_updates + flatpak_updates))

[ "${1}" == upgrade ] && printf "Official:   %-10s\nAUR ($aur_helper):  %-10s\nFlatpak:    %-10s\n\n" "$official_updates" "$aur_updates" "$flatpak_updates" && exit

tooltip="Official:   $official_updates\nAUR ($aur_helper):  $aur_updates\nFlatpak:    $flatpak_updates"

# Module and tooltip
if [ $total_updates -eq 0 ]; then
  echo "{\"text\":\"󰸟\", \"tooltip\":\"Packages are up to date\"}"
else
  echo "{\"text\":\"󰞒\", \"tooltip\":\"${tooltip}\"}"
fi
