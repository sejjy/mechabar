<div align="center">
    <h2>🤖 mechabar</h2>
    <p>A mecha-themed Waybar configuration</p>
</div>

<table>
	<tr>
		<td>
			<img src="assets/social-preview.png" alt="Social Preview" />
		</td>
	</tr>
</table>

<div align="center">
	<details>
		<summary><b>Themes</b></summary>
		<div align="left">
			<p>Catppuccin <b>Mocha</b> (Default)</p>
			<table>
				<tr>
					<td>
						<img src="assets/catppuccin-mocha.png" alt="Catppuccin Mocha" />
					</td>
				</tr>
			</table>
			<p>Catppuccin <b>Macchiato</b></p>
			<table>
				<tr>
					<td>
						<img src="assets/catppuccin-macchiato.png" alt="Catppuccin Macchiato" />
					</td>
				</tr>
			</table>
			<p>Catppuccin <b>Frappe</b></p>
			<table>
				<tr>
					<td>
						<img src="assets/catppuccin-frappe.png" alt="Catppuccin Frappe" />
					</td>
				</tr>
			</table>
			<p>Catppuccin <b>Latte</b></p>
			<table>
				<tr>
					<td>
						<img src="assets/catppuccin-latte.png" alt="Catppuccin Latte" />
					</td>
				</tr>
			</table>
		</div>
	</details>
</div>

#

### Requirements

- [waybar](https://github.com/Alexays/Waybar)

> [!WARNING]
> Version **0.14.0** has an [issue](https://github.com/Alexays/Waybar/issues/4354) that breaks modular configs.
> As a temporary fix, clone the `fix/v14` branch instead.

- A terminal emulator (default: [kitty](https://github.com/kovidgoyal/kitty))

> [!IMPORTANT]
> If you use a different terminal emulator (e.g., [ghostty](https://github.com/ghostty-org/ghostty)),
> replace all invocations of `kitty` with its executable name:

```diff
- "on-click": "kitty -e ..."
+ "on-click": "ghostty -e ..."
```

#

### Installation

1. Backup your current config:

    ```bash
    mv ~/.config/waybar{,.bak}
    ```

2. Clone the repository:

    ```bash
    git clone https://github.com/sejjy/mechabar.git ~/.config/waybar

    # Version 14 fix:
    # git clone -b fix/v14 https://github.com/sejjy/mechabar.git ~/.config/waybar
    ```

3. Run the [install](/install.sh) script:

    ```bash
    ~/.config/waybar/install.sh
    ```

	> This makes the [scripts](/scripts/) executable and installs all dependencies listed below:

	|                        Package | Description                                                                    |
	| -----------------------------: | ------------------------------------------------------------------------------ |
	|                        `bluez` | Daemons for the bluetooth protocol stack<tr></tr>                              |
	| (_bluetoothctl_) `bluez-utils` | Development and debugging utilities for the bluetooth protocol stack<tr></tr>  |
	|                `brightnessctl` | Lightweight brightness control tool<tr></tr>                                   |
	|                          `fzf` | Command-line fuzzy finder<tr></tr>                                             |
	|     (_nmcli_) `networkmanager` | Network connection manager and user applications<tr></tr>                      |
	|               `pipewire-pulse` | Low-latency audio/video router and processor - PulseAudio replacement<tr></tr> |
	|             `ttf-0xproto-nerd` | Patched font 0xProto from nerd fonts library                                   |

#

### Battery

By default, the [battery](/modules/battery.jsonc) module updates every 60 seconds.
To get immediate feedback when the battery state changes (e.g., charging/discharging),
you can set a low interval or enable battery state notifications (recommended).

> [!TIP]
> To enable battery state notifications, see the instructions in [battery-state.sh](/scripts/battery-state.sh#L5-L12).

#

### Credits

- Font: [0xProto](https://github.com/0xType/0xProto)
- Icons: [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
- Themes: [Catppuccin](https://github.com/catppuccin/waybar)
