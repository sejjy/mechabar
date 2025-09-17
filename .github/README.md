<div align="center"><h2>🤖 mechabar</h2></div>

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
			<p>Catppuccin <b>Mocha</b> (<i>Default</i>)</p>
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
	<details>
		<summary><b>Variants</b></summary>
		<div align="left">
			<p><b>pac-man</b> (<i>Pac-Man</i>)</p>
			<table>
				<tr>
					<td>
						<img src="assets/variant-pac-man.png" alt="Pac-Man Variant" />
					</td>
				</tr>
			</table>
			<blockquote>Variants also come in 4 themes.</blockquote>
			<p>More variants soon!</p>
		</div>
	</details>
</div>

#

### Requirements

- [waybar](https://github.com/Alexays/Waybar)

	> Version **0.14.0** has an [issue](https://github.com/Alexays/Waybar/issues/4354) that breaks modular configs
	> ([#31](https://github.com/sejjy/mechabar/issues/31)). As a temporary fix, clone the `fix/v14` branch instead:

   ```bash
   git clone -b fix/v14 https://github.com/sejjy/mechabar.git ~/.config/waybar
   ```

- [kitty](https://github.com/kovidgoyal/kitty) (_optional_)

	> If you use a different terminal emulator (e.g., [ghostty](https://github.com/ghostty-org/ghostty)),
	> replace all invocations of `kitty` with its executable name.

	Example:

   ```jsonc
   // modules/bluetooth.jsonc:
   "on-click": "ghostty -e ~/.config/waybar/scripts/bluetooth.sh"
   ```

#

### Installation

1. Backup your current config:

	```bash
	mv ~/.config/waybar{,.bak}
	```

2. Clone the repository:

	- Default:

	   ```bash
	   git clone https://github.com/sejjy/mechabar.git ~/.config/waybar
	   ```

	- Variant:

	   ```bash
	   # git clone -b <variant> https://github.com/sejjy/mechabar.git ~/.config/waybar
	   # Example:
	   git clone -b pac-man https://github.com/sejjy/mechabar.git ~/.config/waybar
	   ```

3. Run the [install](/install.sh) script:

	```bash
	~/.config/waybar/install.sh
	```

	> This makes [scripts](/scripts/) executable and installs all dependencies listed below:

	|                        Package | Description                                                                    |
	| -----------------------------: | ------------------------------------------------------------------------------ |
	|                        `bluez` | Daemons for the bluetooth protocol stack<tr></tr>                              |
	| (_bluetoothctl_) `bluez-utils` | Development and debugging utilities for the bluetooth protocol stack<tr></tr>  |
	|                `brightnessctl` | Lightweight brightness control tool<tr></tr>                                   |
	|                          `fzf` | Command-line fuzzy finder<tr></tr>                                             |
	|     (_nmcli_) `networkmanager` | Network connection manager and user applications<tr></tr>                      |
	|               `pipewire-pulse` | Low-latency audio/video router and processor - PulseAudio replacement<tr></tr> |
	|             `ttf-0xproto-nerd` | Patched font 0xProto from nerd fonts library                                   |

> [!TIP]
> To enable battery notifications, see the instructions in [battery-state.sh](/scripts/battery-state.sh#L5-L12).

#

### Credits

- Font: [0xProto](https://github.com/0xType/0xProto)
- Icons: [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
- Themes: [Catppuccin](https://github.com/catppuccin/waybar)
