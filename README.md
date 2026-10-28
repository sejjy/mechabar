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

#

> [!IMPORTANT]
> By default, mechabar is configured for
> [Arch-based Linux distributions](https://wiki.archlinux.org/title/Arch-based_distributions)
> and [Hyprland](https://github.com/hyprwm/Hyprland), and uses
> [kitty](https://github.com/kovidgoyal/kitty) to launch command-line
> interfaces. If you use a different distribution, compositor, or terminal, see
> the [Configuration](#configuration) section below.

## Installation

1. Back up your existing Waybar config:

   ```sh
   mv ~/.config/waybar ~/.config/waybar.bak
   ```

2. Clone the repository into <ins>~/.config/waybar</ins>:

   ```sh
   git clone https://github.com/sejjy/mechabar.git ~/.config/waybar
   ```

3. Install the dependencies and restart Waybar:

   ```sh
   ~/.config/waybar/install # Arch-based distros only
   ```

   > See [install](./install) for the list of dependencies.

## Configuration

### For other distributions

Edit the following files:

1. [update](./scripts/update): Uses
   [checkupdates](https://github.com/archlinux/pacman-contrib/blob/master/src/checkupdates.sh.in)
   from [pacman-contrib](https://github.com/archlinux/pacman-contrib)
   to print the number of pending updates and
   [pacman](https://archlinux.org/packages/core/x86_64/pacman) to upgrade
   packages.
2. [distro.jsonc](./modules/custom/distro.jsonc): Uses the Arch Linux icon
   ([nf-md-arch](https://www.nerdfonts.com/cheat-sheet?q=nf-md-arch)).

### For other compositors

[DWL](https://github.com/Alexays/Waybar/wiki/Module:-Dwl)
&nbsp; [Mango](https://github.com/Alexays/Waybar/wiki/Module:-Mango)
&nbsp; [Niri](https://github.com/Alexays/Waybar/wiki/Module:-Niri)
&nbsp; [River](https://github.com/Alexays/Waybar/wiki/Module:-River)
&nbsp; [Sway](https://github.com/Alexays/Waybar/wiki/Module:-Sway)
&nbsp; [Wayfire](https://github.com/Alexays/Waybar/wiki/Module:-Wayfire)

Edit (or create new versions of) the following files:

1. [window.jsonc](./modules/hyprland/window.jsonc)
2. [workspaces.jsonc](./modules/hyprland/workspaces.jsonc)

### For other terminals

Replace <ins>kitty</ins> with your terminal (make sure to change
<ins>TERMINAL</ins>):

```sh
sed -i "s/kitty/TERMINAL/g" \
       ~/.config/waybar/modules/custom/power.jsonc \
       ~/.config/waybar/modules/custom/update.jsonc \
       ~/.config/waybar/modules/hyprland/window.jsonc \
       ~/.config/waybar/modules/optional/taskbar.jsonc \
       ~/.config/waybar/modules/bluetooth.jsonc \
       ~/.config/waybar/modules/network.jsonc
```
