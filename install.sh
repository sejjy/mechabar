#!/usr/bin/env bash

# Exit on error
set -e

if [ "$(basename "$PWD")" != "mechabar" ]; then
  echo "You must run this script from the 'mechabar' directory."
  exit 1
fi

# Check if a package is already installed
check_package() {
  if pacman -Qi "$1" &>/dev/null; then
    printf "\033[1;33m%s is already installed.\033[0m\n" "$1"
  else
    printf "\033[1;32mInstalling %s...\033[0m\n" "$1"
    sudo pacman -S --noconfirm "$1"
  fi
}

# Check if an AUR package is installed
check_aur_package() {
  AUR_HELPER=$(get_aur_helper)

  if [ "$AUR_HELPER" == "none" ]; then
    printf "\n\n\033[1;31mNeither yay nor paru were found. You can manually install the AUR packages.\033[0m\n\n"
    exit 1
  fi

  if $AUR_HELPER -Qi "$1" &>/dev/null; then
    printf "\033[1;33m%s (AUR) is already installed.\033[0m\n" "$1"
  else
    printf "\033[1;32mInstalling %s (AUR)...\033[0m\n" "$1"
    $AUR_HELPER -S --noconfirm "$1"
  fi
}

# Determine the AUR helper (yay or paru)
get_aur_helper() {
  if command -v yay &>/dev/null; then
    echo "yay"
  elif command -v paru &>/dev/null; then
    echo "paru"
  else
    echo "none"
  fi
}

# Required
install_dependencies() {
  printf "\n\033[1;32mInstalling required dependencies...\033[0m\n\n"
  check_package libnotify
  check_package jq
  check_package networkmanager
  check_package bluez
  check_package bluez-utils
  check_package python
  check_package playerctl
  check_package brightnessctl
}

# Recommended (with alternatives)
install_recommended() {
  printf "\n\n\033[1;32mInstalling recommended dependencies...\033[0m\n\n"
  check_package ttf-jetbrains-mono-nerd
  check_package pipewire
  check_package wireplumber
}

# Optional (but recommended)
install_optional() {
  AUR_HELPER=$(get_aur_helper)

  if [ "$AUR_HELPER" == "none" ]; then
    printf "\n\n\033[1;31mNeither yay nor paru were found. You can manually install the AUR packages.\033[0m\n\n"
    exit 1
  fi

  printf "\n\n\033[1;32mUsing %s to install optional dependencies...\033[0m\n\n" "$AUR_HELPER"
  check_aur_package rofi-lbonn-wayland-git
  check_aur_package wlogout
}

# Copy configuration files
copy_configs() {
  printf "\n\n\033[1;32mCopying configuration files...\033[0m\n\n"

  mkdir -p ~/.config/waybar/
  cp config.jsonc style.css theme.css ~/.config/waybar/

  # Rofi
  mkdir -p ~/.config/rofi
  cp -r rofi/* ~/.config/rofi/

  # Wlogout
  mkdir -p ~/.config/wlogout
  cp -r wlogout/* ~/.config/wlogout/
}

# Setup scripts
setup_scripts() {
  printf "\n\n\033[1;32mSetting up scripts...\033[0m\n\n"

  # Waybar-exclusive
  mkdir -p ~/.config/waybar/scripts/
  cp scripts/* ~/.config/waybar/scripts/

  # System-wide
  mkdir -p ~/.local/share/bin/
  cp scripts/brightness-control.sh scripts/volume-control.sh scripts/logout-menu.sh ~/.local/share/bin/

  # Make scripts executable
  chmod +x ~/.config/waybar/scripts/*
  chmod +x ~/.local/share/bin/*
}

# Restart Waybar to apply changes
restart_waybar() {
  printf "\n\n\033[1;32mRestarting Waybar...\033[0m\n\n"

  killall waybar
  nohup waybar >/dev/null 2>&1 &
}

main() {
  install_dependencies
  install_recommended
  install_optional
  copy_configs
  setup_scripts
  restart_waybar

  printf "\n\n\033[1;32mInstallation complete!\033[0m\n\n"
}

main
