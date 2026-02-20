<div align="center">

## 🤖 mechabar

A mecha-themed, modular Waybar configuration.

| ![Mechabar](./assets/catppuccin-mocha.png) |
| :----------------------------------------: |

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

### Prerequisites

1. **[Waybar](https://github.com/Alexays/Waybar)**

> [!IMPORTANT]
> If you have **v0.14.0** installed,
> [clone the `fix/v0.14.0` branch](#clone-fix-branch) instead.

2. A **terminal emulator** (default: Kitty)

> [!IMPORTANT]
> If you use a different emulator, replace all `kitty` commands accordingly. For
> example:
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

	<a name="clone-fix-branch">**For Waybar v0.14.0**</a>:

	```bash
	git clone -b fix/v0.14.0 https://github.com/sejjy/mechabar.git ~/.config/waybar
	```

3. Install the dependencies and restart Waybar:

	```bash
	~/.config/waybar/install
	```

	<details>
	<summary>Dependencies (8)</summary>

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

### Configuration

<details>
<summary><code>user.jsonc</code></summary>

The leftmost module has no default function and is reserved for custom use. You
can configure it to run any command. For example:

```jsonc
// modules/custom/user.jsonc

"custom/trigger": {
	// Run your script
	"on-click": "/path/to/my/script",
	// Restart Waybar
	"on-click-right": "pkill -SIGUSR2 waybar",
}
```

#

</details>

<details>
<summary>Binds</summary>

You can define keybinds to interact with modules using their respective
[scripts](./scripts/). For example:

```properties
# ~/.config/hypr/hyprland.conf

$path = ~/.config/waybar/scripts

# Launch CLI
bind = SUPER, B, exec, kitty -e $path/bluetooth
bind = SUPER, N, exec, kitty -e $path/network
bind = SUPER, O, exec, kitty -e $path/power
bind = SUPER, U, exec, kitty -e $path/update

# Adjust volume/brightness
bindl  = , XF86AudioMicMute,      exec, $path/volume input mute
bindl  = , XF86AudioMute,         exec, $path/volume output mute
bindel = , XF86AudioLowerVolume,  exec, $path/volume output lower
bindel = , XF86AudioRaiseVolume,  exec, $path/volume output raise
bindel = , XF86MonBrightnessDown, exec, $path/backlight down
bindel = , XF86MonBrightnessUp,   exec, $path/backlight up

# Toggle off bluetooth/wifi
bind = SUPER ALT, B, exec, $path/bluetooth off
bind = SUPER ALT, N, exec, $path/network off

# Refresh `update` module
bind = SUPER ALT, U, exec, pkill -RTMIN+1 waybar
```

#

</details>

<details>
<summary>Icons</summary>

You can search for icons on
[Nerd Fonts: Cheat Sheet ↗](https://www.nerdfonts.com/cheat-sheet). For example:

```
battery charging
```

For consistency, most modules use icons from Material Design, prefixed with
`nf-md`:

```
nf-md battery charging
```

#

</details>

<details open>
<summary>Theme</summary>

Copy your preferred theme from the [themes](./themes/) directory to `theme.css`.
For example:

```bash
cd ~/.config/waybar
cp themes/catppuccin-latte.css theme.css
```

</details>

#

### References

- [Hyprland wiki: Binds ↗](https://wiki.hypr.land/Configuring/Binds/)
- [Nerd Fonts wiki: Glyph Sets](https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points)
- [Waybar wiki](https://github.com/Alexays/Waybar/wiki)
