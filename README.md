<div align="center">

# 🤖 mechabar

| ![Preview 1](assets/v1.0.0.png) |
| :-----------------------------: |

  <details>
    <summary><strong>&nbsp;🚀 Menus</strong></summary>
    <br />

|                Wi-Fi                |
| :---------------------------------: |
| ![Wi-Fi Menu](assets/wifi-menu.png) |

|                  Bluetooth                   |
| :------------------------------------------: |
| ![Bluetooth Menu](assets/bluetooth-menu.png) |

|                Power                 |
| :----------------------------------: |
| ![Power Menu](assets/power-menu.png) |

  </details>
</div>

A mecha-themed [Waybar](https://github.com/Alexays/Waybar) configuration initially designed for [Hyprland](https://github.com/hyprwm/Hyprland), but also compatible with [Sway](https://github.com/swaywm/sway)[^1] and other [wlroots-based compositors](https://github.com/solarkraft/awesome-wlroots#compositors) with minimal adjustments.

[^1]:
    Waybar configuration guide for Sway:  
    https://github.com/Alexays/Waybar/wiki/Module:-Sway

<br />

## Installation (Arch Linux)

### Automatic

1. **Clone the repository:**

   ```bash
   git clone https://github.com/sejjy/mechabar.git
   cd mechabar
   ```

2. **Run the [install](/install.sh) script:**

   ```bash
   ./install.sh
   ```

   This backs up existing folders and installs all [dependencies](#i-dependencies), configuration files, and scripts.

#

### Manual

#### I. Dependencies

```bash
sudo pacman -S bluez-utils brightnessctl hyprlock pipewire pipewire-pulse python ttf-jetbrains-mono-nerd wireplumber
```

```bash
yay -S bluetui rofi-lbonn-wayland-git
```

| Package                   | Description                                                                                         |
| ------------------------- | --------------------------------------------------------------------------------------------------- |
| `bluetui`                 | TUI for managing bluetooth devices <tr></tr>                                                        |
| `bluez-utils`             | Development and debugging utilities for the bluetooth protocol stack <tr></tr>                      |
| `brightnessctl`           | Lightweight brightness control tool <tr></tr>                                                       |
| `hyprlock`                | Hyprland's GPU-accelerated screen locking utility <tr></tr>                                         |
| `pipewire`                | Low-latency audio/video router and processor <tr></tr>                                              |
| `pipewire-pulse`          | Low-latency audio/video router and processor - PulseAudio replacement <tr></tr>                     |
| `python`                  | The Python programming language <tr></tr>                                                           |
| `rofi-lbonn-wayland-git`  | A window switcher, application launcher and dmenu replacement (fork with Wayland support) <tr></tr> |
| `ttf-jetbrains-mono-nerd` | Patched font JetBrains Mono from the nerd fonts library <tr></tr>                                   |
| `wireplumber`             | Session/policy manager implementation for PipeWire                                                  |

> [!IMPORTANT]
> If you use alternatives, you may need to modify the [scripts](/scripts/) and configuration files accordingly.

#

#### II. Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/sejjy/mechabar.git
   cd mechabar
   ```

2. **Copy configuration files:**

   ```bash
   mkdir -p ~/.config/waybar/
   cp config.jsonc style.css theme.css ~/.config/waybar/
   ```

   ```bash
   mkdir -p ~/.config/rofi
   cp rofi/* ~/.config/rofi/
   ```

3. **Setup scripts:**

   ```bash
   mkdir -p ~/.config/waybar/scripts/
   cp scripts/* ~/.config/waybar/scripts/
   ```

   ```bash
   chmod +x ~/.config/waybar/scripts/*
   ```

4. **Restart Waybar to apply the changes:**

   ```bash
   killall waybar
   nohup waybar >/dev/null 2>&1 &
   ```

## Customization

- You can change the colors in [theme.css](/theme.css) and [theme.rasi](/rofi/theme.rasi) to match your system theme.
- You can replace existing modules or add new ones from the [modules](/modules/) folder. For a complete list of available modules, visit the [Waybar Wiki](https://github.com/Alexays/Waybar/wiki).

## Roadmap

Here are some features and improvements planned for future versions:

- [x] Install script
- [x] Rofi Bluetooth menu
- [x] Rofi power menu
- [ ] Theme switcher

## Credits

- The original files in the [modules](/modules/) folder are from [prasanthrangan / hyprdots](https://github.com/prasanthrangan/hyprdots).
- Icons: [ryanoasis / nerd-fonts](https://github.com/ryanoasis/nerd-fonts)
- Color palette: [catppuccin / catppuccin](https://github.com/catppuccin/catppuccin) (Mocha)
