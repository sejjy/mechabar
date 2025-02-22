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

restore_backup() {
  printf "\n\033[1;34mRestoring backup config files...\033[0m\n"

  CONFIG_DIR=~/.config
  declare -A FOLDERS=(
    ["waybar"]="waybar-backup"
    ["rofi"]="rofi-backup"
  )

  for DEST in "${!FOLDERS[@]}"; do
    SRC="${FOLDERS[$DEST]}"
    if [ -d "$CONFIG_DIR/${SRC:?}" ]; then
      printf "\033[1;33mRestoring %s from %s...\033[0m\n" "$DEST" "$SRC"
      rm -rf "$CONFIG_DIR/${DEST:?}"
      mv "$CONFIG_DIR/${SRC:?}" "$CONFIG_DIR/${DEST:?}"
    else
      printf "\033[1;34mNo backup found for %s. Skipping restore.\033[0m\n" "$DEST"
    fi
  done
}

remove_packages() {
  printf "\n\033[1;32mRemoving installed dependencies...\033[0m\n"

  if [ ! -f /tmp/mechabar_installed.txt ]; then
    printf "\033[1;33mNo package installation log found. Skipping package removal.\033[0m\n"
    return
  fi

  while IFS= read -r PACKAGE; do
    if pacman -Qi "$PACKAGE" &>/dev/null; then
      if ! pacman -Qdtq | grep -qx "$PACKAGE"; then
        printf "\033[1;33m%s is required by other packages. Skipping removal.\033[0m\n" "$PACKAGE"
      else
        printf "\033[1;31mRemoving %s...\033[0m\n" "$PACKAGE"
        sudo pacman -Rns --noconfirm "$PACKAGE"
      fi
    else
      printf "\033[1;33m%s is not installed. Skipping.\033[0m\n" "$PACKAGE"
    fi
  done </tmp/mechabar_installed.txt

  rm -f /tmp/mechabar_installed.txt
}

remove_aur_packages() {
  AUR_HELPER=$(get_aur_helper)

  printf "\n\033[1;32mUsing %s to remove AUR packages...\033[0m\n" "$AUR_HELPER"

  if [ ! -f /tmp/mechabar_aur_installed.txt ]; then
    printf "\033[1;33mNo AUR package installation log found. Skipping AUR package removal.\033[0m\n"
    return
  fi

  while IFS= read -r PACKAGE; do
    if $AUR_HELPER -Qi "$PACKAGE" &>/dev/null; then
      printf "\033[1;31mRemoving %s (AUR)...\033[0m\n" "$PACKAGE"
      $AUR_HELPER -Rns --noconfirm "$PACKAGE"
    else
      printf "\033[1;33m%s (AUR) is not installed. Skipping.\033[0m\n" "$PACKAGE"
    fi
  done </tmp/mechabar_aur_installed.txt

  rm -f /tmp/mechabar_aur_installed.txt
}

get_aur_helper() {
  if command -v yay &>/dev/null; then
    echo "yay"
  elif command -v paru &>/dev/null; then
    echo "paru"
  else
    printf "\n\033[1;31mNo AUR helper found. Skipping AUR package removal.\033[0m\n"
    exit 1
  fi
}

clean_configs() {
  printf "\n\033[1;32mCleaning up custom config files...\033[0m\n"
  CONFIG_DIR=~/.config

  if [ -d "$CONFIG_DIR/waybar-backup" ]; then
    rm -rf "$CONFIG_DIR/waybar"
  else
    printf "\033[1;33mNo waybar-backup found. Skipping waybar removal.\033[0m\n"
  fi

  if [ -d "$CONFIG_DIR/rofi-backup" ]; then
    rm -rf "$CONFIG_DIR/rofi"
  else
    printf "\033[1;33mNo rofi-backup found. Skipping rofi removal.\033[0m\n"
  fi
}

restart_waybar() {
  printf "\n\033[1;32mRestarting Waybar...\033[0m\n"
  killall waybar || true
  nohup waybar >/dev/null 2>&1 &
}

main() {
  read -r -p "Are you sure you want to remove installed packages and delete config files? (y/N) " confirm
  if [[ "$confirm" != "y" ]]; then
    echo "Uninstallation canceled."
    exit 0
  fi

  restore_backup
  remove_packages
  remove_aur_packages
  clean_configs
  restart_waybar

  printf "\n\033[1;32mUninstallation complete!\033[0m\n\n"
}

main
