<div align="center">

## 🤖 mechabar

A mecha-themed, modular Waybar configuration.

| ![Mechabar](assets/catppuccin-mocha.png) |
| :--------------------------------------: |

<details>
<summary><b>Themes</b></summary>
<br>

**Catppuccin:**

|                Mocha _(default)_                 |
| :----------------------------------------------: |
| ![Catppuccin Mocha](assets/catppuccin-mocha.png) |

|                        Macchiato                         |
| :------------------------------------------------------: |
| ![Catppuccin Macchiato](assets/catppuccin-macchiato.png) |

|                       Frappe                       |
| :------------------------------------------------: |
| ![Catppuccin Frappe](assets/catppuccin-frappe.png) |

|                      Latte                       |
| :----------------------------------------------: |
| ![Catppuccin Latte](assets/catppuccin-latte.png) |

</details>
</div>

#

### Requirements

1. [Waybar](https://github.com/Alexays/Waybar)

> [!WARNING]
> **Version 0.14.0** has an [issue](https://github.com/Alexays/Waybar/issues/4354) with wildcard includes.
> Use the `fix/v0.14.0` branch as a temporary workaround.

2. A terminal emulator _(default: **Kitty**)_

> [!IMPORTANT]
> If you use a different terminal emulator (e.g., **Ghostty**),
> you need to replace all instances of `kitty` with your terminal command:
>
> ```diff
> - "on-click": "kitty -e ..."
> + "on-click": "ghostty -e ..."
> ```

#

### Installation

1. Back up your current configuration:

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

3. Run the [install script](/install.sh):

	```bash
	~/.config/waybar/install.sh
	```

	This makes the [scripts](/scripts/) executable and installs all dependencies listed below:

	|                           Package | Description                                                                    |
	| --------------------------------: | ------------------------------------------------------------------------------ |
	|                           `bluez` | Daemons for the bluetooth protocol stack<tr></tr>                              |
	|    _(bluetoothctl)_ `bluez-utils` | Development and debugging utilities for the bluetooth protocol stack<tr></tr>  |
	|                   `brightnessctl` | Lightweight brightness control tool<tr></tr>                                   |
	|                             `fzf` | Command-line fuzzy finder<tr></tr>                                             |
	|        _(nmcli)_ `networkmanager` | Network connection manager and user applications<tr></tr>                      |
	| _(checkupdates)_ `pacman-contrib` | Contributed scripts and tools for pacman systems<tr></tr>                      |
	|                  `pipewire-pulse` | Low-latency audio/video router and processor - PulseAudio replacement<tr></tr> |
	|                `ttf-0xproto-nerd` | Patched font 0xProto from nerd fonts library                                   |

#

### Customization

- To change the theme, copy the file with your preferred theme (e.g., `catppuccin-latte.css`) to `theme.css`:

    ```bash
    cd ~/.config/waybar
    cp themes/catppuccin-latte.css theme.css
    ```

#

### Documentation

- [Waybar wiki](https://github.com/Alexays/Waybar/wiki)

- Man page:

    ```bash
    man waybar
    ```

#

### Credits

- Font: [0xProto](https://github.com/0xType/0xProto)
- Icons: [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
- Themes: [Catppuccin](https://github.com/catppuccin/waybar)
