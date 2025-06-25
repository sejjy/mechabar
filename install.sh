#!/usr/bin/env bash

# exit on error
set -e

if [ "$(basename "$PWD")" != "mechabar" ]; then
  printf "\n\033[1;31mYou must run this script from the 'mechabar' directory.\033[0m\n"
  exit 1
fi

if ! command -v pacman &>/dev/null; then
  printf "\n\033[1;31mThis script is intended for Arch-based systems only.\033[0m\n"
  exit 1
fi

backup_files() {
  printf "\n\033[1;34mBacking up existing config files...\033[0m\n"

  CONFIG_DIR=~/.config
  declare -A FOLDERS=(
    ["waybar"]="waybar-backup"
    ["rofi"]="rofi-backup"
  )

  for SRC in "${!FOLDERS[@]}"; do
    DEST="${FOLDERS[$SRC]}"
    if [ -d "$CONFIG_DIR/$SRC" ]; then
      printf "\033[1;33mBacking up %s to %s...\033[0m\n" "$SRC" "$DEST"
      cp -r "$CONFIG_DIR/$SRC" "$CONFIG_DIR/$DEST"
    else
      printf "\033[1;34mNo existing %s config found. Skipping backup.\033[0m\n" "$SRC"
    fi
  done
}

check_packages() {
  if pacman -Qi "$1" &>/dev/null; then
    printf "\033[1;33m%s is already installed.\033[0m\n" "$1"
  else
    printf "\033[1;32mInstalling %s...\033[0m\n" "$1"
    sudo pacman -S --noconfirm "$1"
  fi
}

check_aur_packages() {
  AUR_HELPER=$(get_aur_helper)

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
    printf "\n\033[1;31mNeither yay nor paru were found. Install one to proceed:\033[0m\n"
    printf "\033[1;32myay: \033[0msudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si\n"
    printf "\033[1;32mparu: \033[0msudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si\n"
    printf "\n\033[1;31mor use your preferred AUR helper to install these packages:\033[0m\n"
    printf "bluetui\nrofi-lbonn-wayland-git\n"
    printf "\n\033[1;33mOnce installed, rerun the script.\033[0m\n"
    exit 1
  fi
}

install_dependencies() {
  printf "\n\033[1;32mInstalling dependencies...\033[0m\n"

  DEPENDENCIES=(
    bluez-utils brightnessctl pacman-contrib pipewire pipewire-pulse ttf-jetbrains-mono-nerd wireplumber
  )

  for PACKAGE in "${DEPENDENCIES[@]}"; do
    check_packages "$PACKAGE"
  done
}

install_aur_packages() {
  printf "\n\033[1;32mUsing %s to install AUR packages...\033[0m\n" "$(get_aur_helper)"
  check_aur_packages bluetui
  check_aur_packages rofi-lbonn-wayland-git
}

copy_configs() {
  printf "\n\033[1;32mCopying config files...\033[0m\n"

  mkdir -p ~/.config/waybar
  cp config.jsonc style.css theme.css ~/.config/waybar

  mkdir -p ~/.config/waybar/themes
  cp -r themes/* ~/.config/waybar/themes

  mkdir -p ~/.config/rofi
  cp -r rofi/* ~/.config/rofi
}

setup_scripts() {
  printf "\n\033[1;32mSetting up scripts...\033[0m\n"

  mkdir -p ~/.config/waybar/scripts
  cp scripts/* ~/.config/waybar/scripts

  chmod +x ~/.config/waybar/scripts/*
}

restart_waybar() {
  printf "\n\033[1;32mRestarting Waybar...\033[0m\n"

  pkill waybar 2>/dev/null || true
  nohup waybar --config "$HOME/.config/waybar/config.jsonc" --style "$HOME/.config/waybar/style.css" >/dev/null 2>&1 &
}

main() {
  backup_files
  install_dependencies
  install_aur_packages
  copy_configs
  setup_scripts
  restart_waybar

  printf "\n\033[1;32mInstallation complete!\033[0m\n\n"
}

main
