<div align="center">

## 🤖 mechabar

A <ins>mecha</ins>-themed Way<ins>bar</ins> configuration

| ![Default](./assets/catppuccin-mocha.png) |
| :---------------------------------------: |

<details>
<summary>Themes</summary>

| Catppuccin Mocha (default)                         |
| :------------------------------------------------: |
| ![Catppuccin Mocha](./assets/catppuccin-mocha.png) |

| Catppuccin Macchiato                                       |
| :--------------------------------------------------------: |
| ![Catppuccin Macchiato](./assets/catppuccin-macchiato.png) |

| Catppuccin Frappe                                    |
| :--------------------------------------------------: |
| ![Catppuccin Frappe](./assets/catppuccin-frappe.png) |

| Catppuccin Latte                                   |
| :------------------------------------------------: |
| ![Catppuccin Latte](./assets/catppuccin-latte.png) |

</details>
</div>

> [!IMPORTANT]
> By default, mechabar is configured for [Arch Linux](https://archlinux.org/)
> and [Hyprland](https://github.com/hyprwm/Hyprland), and uses
> [Kitty](https://github.com/kovidgoyal/kitty) to launch command-line
> interfaces. If you use a different distribution, compositor, or terminal, see
> the [Configuration](#configuration) section below.

## Installation

1. Back up your current Waybar configuration:

   ```sh
   $ mv ~/.config/waybar ~/.config/waybar.bak
   ```

2. Clone the repository into <ins>~/.config/waybar</ins>:

   ```sh
   $ git clone https://github.com/sejjy/mechabar.git ~/.config/waybar
   ```

3. Install the following dependencies:

   ```text
   bluez-utils brightnessctl fzf libnotify networkmanager ttf-googlesanscode-nerd pacman-contrib
   ```

4. Restart Waybar:

   ```sh
   $ pkill -SIGUSR2 waybar
   ```

## Configuration

### Distribution

[update](./scripts/update) uses
[checkupdates](https://man.archlinux.org/man/checkupdates.8) from
[pacman-contrib](https://archlinux.org/packages/extra/x86_64/pacman-contrib/) to
display update counts and [pacman](https://man.archlinux.org/man/pacman.8) to
upgrade packages. If you use a non-Arch-based Linux distribution...

```text
Bailing out, you are on your own now. Good luck.
```

But seriously, you can edit the script, use your own, or simply not use the
module at all.

### Compositor

[config.jsonc](./config.jsonc) uses <ins>hyprland/window</ins> to display the
title of the currently focused window. If you use
[Niri](https://github.com/niri-wm/niri), for example, simply replace
<ins>hyprland/window</ins> with <ins>niri/window</ins>. See the
[Waybar wiki](https://github.com/Alexays/Waybar/wiki) for more information.

### Terminal

[bluetooth.jsonc](./modules/bluetooth.jsonc),
[network.jsonc](./modules/network.jsonc),
[power.jsonc](./modules/custom/power.jsonc), and
[update.jsonc](./modules/custom/update.jsonc) use Kitty to launch their
respective command-line interfaces. If you use
[WezTerm](https://github.com/wezterm/wezterm), for example, simply replace
<ins>kitty -e</ins> with <ins>wezterm -e</ins>.
