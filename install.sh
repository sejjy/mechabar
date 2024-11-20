#!/usr/bin/env bash

# Exit on error
set -e

if [ "$(basename "$PWD")" != "mechabar" ]; then
  printf "\n\033[1;31mYou must run this script from the 'mechabar' directory.\033[0m\n"
  exit 1
fi

if ! command -v pacman &>/dev/null; then
  printf "\n\033[1;31mThis script is intended for Arch-based systems only.\033[0m\n"
  exit 1
fi

backup() {
  printf "\n\033[1;34mBacking up existing config files...\033[0m\n"

  CONFIG_DIR=~/.config
  TIMESTAMP=$(date +%m-%Y)
  declare -A FOLDERS=(
    ["waybar"]="waybar-backup-$TIMESTAMP"
    ["rofi"]="rofi-backup-$TIMESTAMP"
    ["wlogout"]="wlogout-backup-$TIMESTAMP"
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
    printf "\033[1;32mFor yay: \033[0msudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si\n"
    printf "\033[1;32mFor paru: \033[0msudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si\n"
    printf "\n\033[1;31mor use your preferred AUR helper to install these packages:\033[0m\n"
    printf "rofi-lbonn-wayland-git\nwlogout\n"
    printf "\n\033[1;33mOnce installed, rerun the script.\033[0m\n"
    exit 1
  fi
}

# Install required dependencies
install_dependencies() {
  printf "\n\033[1;32mInstalling dependencies...\033[0m\n"

  DEPENDENCIES=(
    bluez-utils brightnessctl jq pipewire python ttf-jetbrains-mono-nerd wireplumber
  )

  for PACKAGE in "${DEPENDENCIES[@]}"; do
    check_package "$PACKAGE"
  done
}

# Install optional dependencies
install_optional() {
  printf "\n\033[1;32mUsing %s to install optional dependencies...\033[0m\n" "$(get_aur_helper)"
  check_aur_package bluetui
  check_aur_package rofi-lbonn-wayland-git
  check_aur_package wlogout
}

# Copy configuration files
copy_configs() {
  printf "\n\033[1;32mCopying config files...\033[0m\n"

  mkdir -p ~/.config/waybar/
  cp config.jsonc style.css theme.css ~/.config/waybar/

  # Rofi
  mkdir -p ~/.config/rofi
  cp rofi/* ~/.config/rofi/

  # Wlogout
  mkdir -p ~/.config/wlogout
  cp -r wlogout/* ~/.config/wlogout/
}

# Setup scripts
setup_scripts() {
  printf "\n\033[1;32mSetting up scripts...\033[0m\n"

  # Waybar-exclusive
  mkdir -p ~/.config/waybar/scripts/
  cp scripts/bluetooth-menu.sh scripts/cpu-temp.sh scripts/cpu-usage.sh scripts/media-player.py scripts/system-update.sh scripts/wifi-menu.sh scripts/wifi-status.sh ~/.config/waybar/scripts/

  # System-wide
  mkdir -p ~/.local/share/bin/
  cp scripts/brightness-control.sh scripts/logout-menu.sh scripts/volume-control.sh ~/.local/share/bin/

  # Make scripts executable
  chmod +x ~/.config/waybar/scripts/*
  chmod +x ~/.local/share/bin/*
}

# Restart Waybar to apply changes
restart_waybar() {
  printf "\n\033[1;32mRestarting Waybar...\033[0m\n"

  killall waybar || true
  nohup waybar >/dev/null 2>&1 &
}

main() {
  backup
  install_dependencies
  install_optional
  copy_configs
  setup_scripts
  restart_waybar

  printf "\n\033[1;32mInstallation complete!\033[0m\n\n"
}

main
