<div align="center">

## 🤖 mechabar

A mecha-themed, modular Waybar configuration

| ![Preview](./assets/catppuccin-mocha.png) |
| :---------------------------------------: |

<details>
<summary>Themes</summary>

<ins><b>Catppuccin:</b></ins>

| Mocha (default)                                    |
| :------------------------------------------------: |
| ![Catppuccin Mocha](./assets/catppuccin-mocha.png) |

| Macchiato                                                  |
| :--------------------------------------------------------: |
| ![Catppuccin Macchiato](./assets/catppuccin-macchiato.png) |

| Frappe                                               |
| :--------------------------------------------------: |
| ![Catppuccin Frappe](./assets/catppuccin-frappe.png) |

| Latte                                              |
| :------------------------------------------------: |
| ![Catppuccin Latte](./assets/catppuccin-latte.png) |

Feel free to open a pull request to add new themes! :^)

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
	<summary>Dependencies (6)</summary>

	| Package                | Command         | Description                                                                    |
	| ---------------------- | --------------- | ------------------------------------------------------------------------------ |
	| `bluez-utils`          | `bluetoothctl`  | Development and debugging utilities for the bluetooth protocol stack<tr></tr>  |
	| `brightnessctl`        | `brightnessctl` | Lightweight brightness control tool<tr></tr>                                   |
	| `fzf`                  | `fzf`           | Command-line fuzzy finder<tr></tr>                                             |
	| `networkmanager`       | `nmcli`         | Network connection manager and user applications<tr></tr>                      |
	| `pacman-contrib`       | `checkupdates`  | Contributed scripts and tools for pacman systems<tr></tr>                      |
	| `otf-commit-mono-nerd` |                 | Patched font Commit Mono from nerd fonts library                               |

	</details>

#

### Configuration

<details open>
<summary>Terminal emulator</summary>

If you use a different terminal emulator, replace every instance of `kitty` in the module files. For example:

```diff
- "on-click": "kitty -e ..."
+ "on-click": "ghostty -e ..."
```

#

</details>

<details open>
<summary>Theme</summary>

To change the theme, copy your preferred file from the [themes](./themes/) directory to `theme.css`. For example:

```bash
cd ~/.config/waybar
cp themes/catppuccin-latte.css theme.css
```

#

</details>

<details>
<summary>Custom module</summary>

The leftmost module has no default function and is _left_ for you to configure. For example:

```jsonc
// ~/.config/waybar/modules/custom/user.jsonc

"custom/user": {
	// Run your own script
	"on-click": "/path/to/your/script",
	// Restart Waybar
	"on-click-right": "pkill -SIGUSR2 waybar",
}
```

#

</details>

<details>
<summary>Icons</summary>

You can search for icons on [Nerd Fonts: Cheat Sheet ↗](https://www.nerdfonts.com/cheat-sheet). For example:

```
gentoo
```

_Matches: `nf-dev-gentoo`, `nf-linux-gentoo`, `nf-md-gentoo`*_

_*Most modules use Material Design Icons (`nf-md-*`) for consistency._

#

</details>

#

### References

- [Waybar wiki](https://github.com/Alexays/Waybar/wiki)
- [Nerd Fonts wiki: Glyph Sets](https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points)
