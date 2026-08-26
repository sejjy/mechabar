<div align="center">

## 🤖 mechabar

A customizable, modular Waybar configuration

| ![Preview](./assets/catppuccin-mocha.png) |
| :---------------------------------------: |

<sup>Screenshot from a 1920×1080 monitor, scaled to 150%.</sup>

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

### Requirements

1. [waybar](https://archlinux.org/packages/extra/x86_64/waybar/)

2. A terminal emulator (default: [kitty](https://archlinux.org/packages/extra/x86_64/kitty/))
	> If you use a different terminal emulator, see the [Configuration](#configuration) section below.

#

### Installation

1. Back up your current Waybar configuration:

	```bash
	mv ~/.config/waybar{,.bak}
	```

2. Clone the repository:

	```bash
	git clone https://github.com/sejjy/mechabar.git ~/.config/waybar
	```

3. Install the dependencies and restart Waybar:

	```bash
	~/.config/waybar/install
	```

	<details>
	<summary>Dependencies (7)</summary>

	| Package                | Command         | Description                                                                   |
	| ---------------------- | --------------- | ----------------------------------------------------------------------------- |
	| `bluez-utils`          | `bluetoothctl`  | Development and debugging utilities for the bluetooth protocol stack<tr></tr> |
	| `brightnessctl`        | `brightnessctl` | Lightweight brightness control tool<tr></tr>                                  |
	| `fzf`                  | `fzf`           | Command-line fuzzy finder<tr></tr>                                            |
	| `libnotify`            | `notify-send`   | Library for sending desktop notifications<tr></tr>                            |
	| `networkmanager`       | `nmcli`         | Network connection manager and user applications<tr></tr>                     |
	| `pacman-contrib`       | `checkupdates`  | Contributed scripts and tools for pacman systems                              |

	Optional (but recommended):

	| Package                | Description                                      |
	| ---------------------- | ------------------------------------------------ |
	| `otf-commit-mono-nerd` | Patched font Commit Mono from nerd fonts library |

	> Different fonts render characters in different sizes, which can affect the layout.
	> If you prefer a different font, you can edit the font properties in `style.css`.

	</details>

#

### Configuration

<details open>
<summary>Terminal</summary>

If you use a different terminal emulator, replace every instance of `kitty` in the module files.
For example:

```jsonc
// ~/.config/waybar/modules/custom/power.jsonc

"custom/power": {
	// "on-click": "kitty -e ~/.config/waybar/scripts/power",
	"on-click": "ghostty -e ~/.config/waybar/scripts/power",
}
```

#

</details>

<details>
<summary>Themes</summary>

To change the theme, import your preferred theme file from the [themes](./themes/) directory to `style.css`.
For example:

```css
/* @import "themes/catppuccin-mocha.css"; */
@import "themes/catppuccin-latte.css";
```

#

</details>

<details>
<summary>Icons</summary>

You can search for icons on [Nerd Fonts: Cheat Sheet ↗](https://www.nerdfonts.com/cheat-sheet).
For example:

```
gentoo
```

This matches <ins>nf-dev-gentoo</ins>, <ins>nf-linux-gentoo</ins>, and <ins>nf-md-gentoo</ins>.

> Most modules use [Material Design Icons](https://github.com/Templarian/MaterialDesign).
> In this case, you may want to use <ins>nf-md-gentoo</ins> for consistency.

#

</details>

<details>
<summary>Custom module</summary>

The leftmost module has no default function and is left for you to configure.
For example:

```jsonc
// ~/.config/waybar/modules/custom/user.jsonc

"custom/user": {
	"on-click": "/path/to/your/script", // Run your own script
	"on-click-right": "pkill -SIGUSR2 waybar", // Restart Waybar
}
```

</details>

#

### References

- [Waybar wiki](https://github.com/Alexays/Waybar/wiki)
- [Nerd Fonts wiki](https://github.com/ryanoasis/nerd-fonts/wiki)
