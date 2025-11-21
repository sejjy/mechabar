<div align="center">

## 🤖 mechabar

A mecha-themed, modular Waybar configuration.

| ![Mechabar](assets/catppuccin-mocha.png) |
| :--------------------------------------: |

<details>
<summary><b>Themes</b></summary>

<ins><b>Catppuccin:</b></ins>

| Mocha (default)                                  |
| :----------------------------------------------: |
| ![Catppuccin Mocha](assets/catppuccin-mocha.png) |

| Macchiato                                                |
| :------------------------------------------------------: |
| ![Catppuccin Macchiato](assets/catppuccin-macchiato.png) |

| Frappe                                             |
| :------------------------------------------------: |
| ![Catppuccin Frappe](assets/catppuccin-frappe.png) |

| Latte                                            |
| :----------------------------------------------: |
| ![Catppuccin Latte](assets/catppuccin-latte.png) |

</details>
</div>

#

### Requirements

1. [Waybar](https://github.com/Alexays/Waybar)

> [!WARNING]
> **Version 0.14.0** has an [issue](https://github.com/Alexays/Waybar/issues/4354) with wildcard includes.
> Clone the `fix/v0.14.0` branch as a temporary workaround.

2. A terminal emulator (default: `kitty`)

> [!IMPORTANT]
> If you use a different terminal emulator (e.g., `ghostty`),
> you need to replace all invocations of `kitty` with your terminal command:
>
> ```diff
> - "on-click": "kitty -e ..."
> + "on-click": "ghostty -e ..."
> ```

#

### Installation

1. Back up your current config:

	```bash
	mv ~/.config/waybar{,.bak}
	```

2. Clone the repository:

	```bash
	git clone https://github.com/sejjy/mechabar.git ~/.config/waybar
	```

	For **Waybar v0.14.0**:

	```bash
	git clone -b fix/v0.14.0 https://github.com/sejjy/mechabar.git ~/.config/waybar
	```

3. Run [`install.sh`](/install.sh):

	```bash
	~/.config/waybar/install.sh
	```

	> This makes the [scripts](/scripts/) executable and installs the following dependencies:

	| Package                | Command         | Description                                                                    |
	| ---------------------- | --------------- | -----------------------------------------------------------------------------  |
	| `bluez`                | -               | Daemons for the bluetooth protocol stack<tr></tr>                              |
	| `bluez-utils`          | `bluetoothctl`  | Development and debugging utilities for the bluetooth protocol stack<tr></tr>  |
	| `brightnessctl`        | `brightnessctl` | Lightweight brightness control tool<tr></tr>                                   |
	| `fzf`                  | `fzf`           | Command-line fuzzy finder<tr></tr>                                             |
	| `networkmanager`       | `nmcli`         | Network connection manager and user applications<tr></tr>                      |
	| `pacman-contrib`       | `checkupdates`  | Contributed scripts and tools for pacman systems<tr></tr>                      |
	| `pipewire-pulse`       | -               | Low-latency audio/video router and processor - PulseAudio replacement<tr></tr> |
	| `otf-commit-mono-nerd` | -               | Patched font Commit Mono from nerd fonts library                               |

#

### Customization

- #### Height

	Adjust the font sizes in [`fonts.css`](/styles/fonts.css).

- #### Icons

	You can search icons from [Nerd Fonts: Cheat Sheet](https://www.nerdfonts.com/cheat-sheet):

   ```
   <icon_name>
   Ex. fedora
   ```

	Most modules use icons from `md` (Material Design) icon set. To search icons from a set, use:

   ```
   nf-<set> <icon_name>
   Ex. nf-md fedora
   ```

	See [Nerd Fonts wiki: Glyph Sets](https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points#glyph-sets) for more details.

- #### Theme

	Copy your preferred theme from the [themes](/themes/) directory into `theme.css`:

   ```bash
   cd ~/.config/waybar
   cp themes/<theme-name>.css theme.css
   ```

	Feel free to open a pull request if you'd like to add themes. :^)

#

### Roadmap

- [ ] Support other compositors out of the box
- [ ] Add a vertical layout
- [ ] Add variants (e.g., Pac-Man)

#

### Documentation

- [Waybar wiki](https://github.com/Alexays/Waybar/wiki)

- Man pages:

   ```bash
   man waybar
   man waybar-styles
   man waybar-custom
   man waybar-<module>
   man waybar-<compositor>-<module>
   ```

#

### Credits

- Themes: [Catppuccin](https://github.com/catppuccin/waybar)
- Original font: [Commit Mono](https://github.com/eigilnikolajsen/commit-mono)
- Patched font & icons: [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
