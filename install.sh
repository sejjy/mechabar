#!/usr/bin/env bash

# Exit on error
set -e

if [ ! -d "mechabar" ]; then
  printf "\n\033[1;31mYou must run this script from the 'mechabar' directory.\033[0m\n\n"
  exit 1
fi

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
  sudo pacman -S --noconfirm libnotify jq networkmanager bluez bluez-utils python playerctl brightnessctl
}

# Recommended (with alternatives)
install_recommended() {
  printf "\n\n\033[1;32mInstalling recommended dependencies...\033[0m\n\n"
  sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd pipewire wireplumber
}

# Optional (but recommended)
install_optional() {
  AUR_HELPER=$(get_aur_helper)

  if [ "$AUR_HELPER" == "none" ]; then
    printf "\n\n\033[1;31myay or paru not found. Perform manual installation with your preferred AUR helper.\033[0m\n\n"
    exit 1
  fi

  printf "\n\n\033[1;32mUsing %s to install optional dependencies...\033[0m\n\n" "$AUR_HELPER"
  $AUR_HELPER -S --noconfirm rofi-lbonn-wayland-git wlogout
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
  killall waybar || true
  waybar &
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
