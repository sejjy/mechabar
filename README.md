<div align="center">

## 🤖 mechabar

A mecha-themed, modular Waybar configuration.

| ![Mechabar](./assets/catppuccin-mocha.png) |
| :--------------------------------------: |

<details>
<summary>Themes</summary>

<ins><b>Catppuccin:</b></ins>

| Mocha (default)                                  |
| :----------------------------------------------: |
| ![Catppuccin Mocha](./assets/catppuccin-mocha.png) |

| Macchiato                                                |
| :------------------------------------------------------: |
| ![Catppuccin Macchiato](./assets/catppuccin-macchiato.png) |

| Frappe                                             |
| :------------------------------------------------: |
| ![Catppuccin Frappe](./assets/catppuccin-frappe.png) |

| Latte                                            |
| :----------------------------------------------: |
| ![Catppuccin Latte](./assets/catppuccin-latte.png) |

Feel free to open a pull request if you'd like to add themes! :^)

</details>
</div>

#

### Prerequisites

1. **[Waybar](https://github.com/Alexays/Waybar)**

> [!WARNING]
> **Waybar v0.14.0** introduced an [issue](https://github.com/Alexays/Waybar/issues/4354) that breaks [wildcard includes](./config.jsonc#L3-L10).
> [Clone the `fix/v0.14.0` branch](#clone-fix-branch) as a temporary workaround.

2. A **terminal emulator** (default: `kitty`)

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

	<a name="clone-fix-branch">For **Waybar v0.14.0**</a>:

	```bash
	git clone -b fix/v0.14.0 https://github.com/sejjy/mechabar.git ~/.config/waybar
	```

3. Run [`install.sh`](./install.sh):

	```bash
	~/.config/waybar/install.sh
	```

	This makes the [scripts](./scripts/) executable and installs the following dependencies:

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
<summary>Binds</summary>

You can set keybinds to interact with modules via [scripts](./scripts/). Example:

```properties
# ~/.config/hypr/hyprland.conf

$mod  = SUPER
$term = kitty
$scr  = ~/.config/waybar/scripts

bind = $mod, B, exec, $term -e $scr/bluetooth.sh
bind = $mod, N, exec, $term -e $scr/network.sh
bind = $mod, O, exec, $term -e $scr/power-menu.sh
bind = $mod, U, exec, $term -e $scr/system-update.sh

bindl  = , XF86AudioMicMute,      exec, $scr/volume.sh input mute
bindl  = , XF86AudioMute,         exec, $scr/volume.sh output mute
bindel = , XF86AudioLowerVolume,  exec, $scr/volume.sh output lower
bindel = , XF86AudioRaiseVolume,  exec, $scr/volume.sh output raise
bindel = , XF86MonBrightnessDown, exec, $scr/backlight.sh down
bindel = , XF86MonBrightnessUp,   exec, $scr/backlight.sh up
```

#

</details>

<details>
<summary>Icons</summary>

You can search for icons on [Nerd Fonts: Cheat Sheet ↗](https://www.nerdfonts.com/cheat-sheet). Example:

```
battery charging
```

For consistency, most modules use icons from Material Design, prefixed with `nf-md`:

```
nf-md battery charging
```

See [Nerd Fonts wiki: Glyph Sets](https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points#glyph-sets) for more info.

#

</details>

<details open>
<summary>Theme</summary>

Copy your preferred theme from the [themes](./themes/) directory into `current-theme.css`. Example:

```bash
cd ~/.config/waybar
cp themes/catppuccin-latte.css current-theme.css
```

</details>

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
- Patched font: [CommitMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/CommitMono)
