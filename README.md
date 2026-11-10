<div align="center">

## 🤖 mechabar

A <ins>mecha</ins>-themed Way<ins>bar</ins> configuration

| ![Default](./assets/catppuccin-mocha.png) |
| :---------------------------------------: |

<details>
<summary>Themes</summary>

| Catppuccin Frappe                                    |
| :--------------------------------------------------: |
| ![Catppuccin Frappe](./assets/catppuccin-frappe.png) |

| Catppuccin Latte                                   |
| :------------------------------------------------: |
| ![Catppuccin Latte](./assets/catppuccin-latte.png) |

| Catppuccin Macchiato                                       |
| :--------------------------------------------------------: |
| ![Catppuccin Macchiato](./assets/catppuccin-macchiato.png) |

| Catppuccin Mocha (default)                         |
| :------------------------------------------------: |
| ![Catppuccin Mocha](./assets/catppuccin-mocha.png) |

| GitHub Dark                              |
| :--------------------------------------: |
| ![GitHub Dark](./assets/github-dark.png) |

| Monochrome                             |
| :------------------------------------: |
| ![Monochrome](./assets/monochrome.png) |

</details>
</div>

> [!IMPORTANT]
> By default, mechabar is configured for [Arch Linux](https://archlinux.org/)
> and [Hyprland](https://github.com/hyprwm/Hyprland), and uses
> [`kitty`](https://github.com/kovidgoyal/kitty) to launch command-line
> interfaces. If you use a different distribution, compositor, or terminal, see
> the [Configuration](#configuration) section below.

## Installation

1. Back up your current Waybar configuration:

   ```sh
   $ mv ~/.config/waybar ~/.config/waybar.bak
   ```

2. Clone the repository into `~/.config/waybar`:

   ```sh
   $ git clone https://github.com/sejjy/mechabar.git ~/.config/waybar
   ```

3. Install the following dependencies:

   ```text
   bluez-utils brightnessctl fzf libnotify networkmanager ttf-googlesanscode-nerd pacman-contrib
   ```

4. Reload `waybar`:

   ```sh
   $ pkill -SIGUSR2 waybar
   ```

## Configuration

<details>
<summary>Distribution</summary>

The [update script](./scripts/update), used by the
[update module](./modules/custom/update.jsonc), uses the
[`checkupdates`](https://man.archlinux.org/man/checkupdates.8) command from the
[pacman-contrib](https://archlinux.org/packages/extra/x86_64/pacman-contrib/)
package to display the number of pending updates and the
[`pacman`](https://man.archlinux.org/man/pacman.8) command to install updates.
If you use a non-Arch-based Linux distribution, you can replace these commands,
use your own script, or not use the module at all.
#
</details>

<details>
<summary>Compositor</summary>

The [config file](./config.jsonc) uses the
[hyprland/window](https://github.com/Alexays/Waybar/wiki/Module:-Hyprland#hyprlandwindow)
module to display the title of the currently focused window. If you use the
[Niri](https://github.com/niri-wm/niri) compositor, for example, use the
[niri/window](https://github.com/Alexays/Waybar/wiki/Module:-Niri#niriwindow)
module instead:

```jsonc
"modules-left": [
	// "hyprland/window"
	"niri/window"
]
```

[List of supported compositors](https://github.com/Alexays/Waybar#compositor-integration).
#
</details>

<details>
<summary>Terminal</summary>

The [bluetooth](./modules/bluetooth.jsonc),
[network](./modules/network.jsonc),
[power](./modules/custom/power.jsonc), and
[update](./modules/custom/update.jsonc) modules use the `kitty` command to
launch their command-line interfaces. If you use the
[WezTerm](https://github.com/wezterm/wezterm) terminal, for example, use the
`wezterm` command instead:

```jsonc
"custom/power": {
	// "on-click": "kitty -e ~/.config/waybar/scripts/power",
	"on-click": "wezterm -e ~/.config/waybar/scripts/power",
}
```
#
</details>

<details>
<summary>Theme</summary>

The [style file](./style.css) uses the
[Catppuccin Mocha](./themes/catppuccin-mocha.css) theme by default. If you
prefer to use [Monochrome](./themes/monochrome.css), for example, import
`monochrome.css` instead:

```css
/* @import "themes/catppuccin-mocha.css"; */
@import "themes/monochrome.css";
```

</details>
