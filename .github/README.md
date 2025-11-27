<div align="center">

## 🤖 mechabar

A mecha-themed, modular Waybar configuration.

| ![Mechabar](assets/catppuccin-mocha.png) |
| :--------------------------------------: |

<details>
<summary>Themes</summary>

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

Feel free to open a pull request if you'd like to add themes. :^)

</details>
</div>

#

### Prerequisites

1. **[Waybar](https://github.com/Alexays/Waybar)**

> [!WARNING]
> **Waybar v0.14.0** introduced an [issue](https://github.com/Alexays/Waybar/issues/4354) that breaks [wildcard includes](/config.jsonc#L3-L10).
> [Clone the `fix/v0.14.0` branch](#clone-anchor-point) as a temporary workaround.

2. A **terminal emulator** (default: `kitty`)

> [!IMPORTANT]
> If you use a different terminal emulator (e.g., `ghostty`),
> you need to replace all invocations of `kitty` with your terminal command:
>
> ```diff
> - "on-click": "kitty -e ..."
> + "on-click": "ghostty -e ..."
> ```

3. **Bash 3.1 or newer**

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

	<a name="clone-anchor-point">For **Waybar v0.14.0**</a>:

	```bash
	git clone -b fix/v0.14.0 https://github.com/sejjy/mechabar.git ~/.config/waybar
	```

3. Run [`install.sh`](/install.sh):

	```bash
	~/.config/waybar/install.sh
	```

	This makes the [scripts](/scripts/) executable and installs the following dependencies:

	<details>
	<summary>Packages (8)</summary>

	| Package                | Command         | Description                                                                    |
	| ---------------------- | --------------- | ------------------------------------------------------------------------------ |
	| `bluez`                | -               | Daemons for the bluetooth protocol stack<tr></tr>                              |
	| `bluez-utils`          | `bluetoothctl`  | Development and debugging utilities for the bluetooth protocol stack<tr></tr>  |
	| `brightnessctl`        | `brightnessctl` | Lightweight brightness control tool<tr></tr>                                   |
	| `fzf`                  | `fzf`           | Command-line fuzzy finder<tr></tr>                                             |
	| `networkmanager`       | `nmcli`         | Network connection manager and user applications<tr></tr>                      |
	| `pacman-contrib`       | `checkupdates`  | Contributed scripts and tools for pacman systems<tr></tr>                      |
	| `pipewire-pulse`       | -               | Low-latency audio/video router and processor - PulseAudio replacement<tr></tr> |
	| `otf-commit-mono-nerd` | -               | Patched font Commit Mono from nerd fonts library                               |

	</details>

#

### Customization

<details>
<summary>Icons</summary>

You can search icons on [Nerd Fonts: Cheat Sheet](https://www.nerdfonts.com/cheat-sheet):

```
<icon_name>
fedora
```

Most modules use icons from `md` (Material Design) icon set. To search icons from a set, use:

```
nf-<set> <icon_name>
nf-md fedora
```

See [Nerd Fonts wiki: Glyph Sets](https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points#glyph-sets) for more details.

#

</details>

<details>
<summary>Keybinds</summary>

You can use the [scripts](/scripts/) to interact with modules through keybinds:

```properties
# ~/.config/hypr/hyprland.conf

$mod     = SUPER
$term    = kitty
$scripts = ~/.config/waybar/scripts

bind = $mod, B, exec, $term -e $scripts/bluetooth.sh
bind = $mod, N, exec, $term -e $scripts/network.sh
bind = $mod, O, exec, $term -e $scripts/power-menu.sh
bind = $mod, U, exec, $term -e $scripts/system-update.sh

bindl  = , XF86AudioMicMute,      exec, $scripts/volume.sh input mute
bindl  = , XF86AudioMute,         exec, $scripts/volume.sh output mute
bindel = , XF86AudioLowerVolume,  exec, $scripts/volume.sh output lower
bindel = , XF86AudioRaiseVolume,  exec, $scripts/volume.sh output raise
bindel = , XF86MonBrightnessDown, exec, $scripts/backlight.sh down
bindel = , XF86MonBrightnessUp,   exec, $scripts/backlight.sh up
```

#

</details>

<details open>
<summary>Theme</summary>

Copy your preferred theme from the [themes](/themes/) directory into `current-theme.css`:

```bash
cd ~/.config/waybar
cp themes/<theme-name>.css current-theme.css
```

</details>

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
