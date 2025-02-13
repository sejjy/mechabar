> [!NOTE]
> You are currently on the **`animated`** branch, which is still in development. This branch introduces a new feature: **launch animations**.

<div align="center">

# 🤖 mechabar

| ![Preview 1](assets/2x-scale.png) |
| :-------------------------------: |

> _<div align="left">See the [assets](/assets/) folder for more preview images.</div>_

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

## Classic vs Animated

You can choose between two (2) styles:

- **Classic:**

  Clone the [`main`](https://github.com/sejjy/mechabar) branch (default) for the classic, non-animated bar.

  ```bash
    git clone https://github.com/sejjy/mechabar.git
    cd mechabar
  ```

- **Animated:**

  Clone the `animated` branch to try the new launch animations.

  ```bash
    git clone -b animated https://github.com/sejjy/mechabar.git
    cd mechabar
  ```

## Installation (Arch Linux)

### Automatic

1. **Run the [install script](/install.sh):**

   ```bash
   ./install.sh
   ```

   This backs up existing folders and installs all [dependencies](#i-dependencies), configuration files, and scripts.

#

### Manual

#### I. Dependencies

```bash
sudo pacman -S bluez-utils brightnessctl pipewire pipewire-pulse python ttf-jetbrains-mono-nerd wireplumber
```

```bash
yay -S bluetui rofi-lbonn-wayland-git
```

| Package                   | Description                                                                                         |
| ------------------------- | --------------------------------------------------------------------------------------------------- |
| `bluetui`                 | TUI for managing bluetooth devices <tr></tr>                                                        |
| `bluez-utils`             | Development and debugging utilities for the bluetooth protocol stack <tr></tr>                      |
| `brightnessctl`           | Lightweight brightness control tool <tr></tr>                                                       |
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

1. **Copy configuration files:**

   ```bash
   mkdir -p ~/.config/waybar/
   cp config.jsonc style.css theme.css ~/.config/waybar/
   ```

   ```bash
   mkdir -p ~/.config/rofi
   cp rofi/* ~/.config/rofi/
   ```

2. **Setup scripts:**

   ```bash
   mkdir -p ~/.config/waybar/scripts/
   cp scripts/* ~/.config/waybar/scripts/
   ```

   ```bash
   chmod +x ~/.config/waybar/scripts/*
   ```

3. **Restart Waybar to apply the changes:**

   ```bash
   killall waybar
   nohup waybar >/dev/null 2>&1 &
   ```

## Customization

- You can change the colors in [theme.css](/theme.css) and [theme.rasi](/rofi/theme.rasi) to match your system theme.
- You can replace existing modules or add new ones from the [modules](/modules/) folder. For a complete list of available modules, visit the [Waybar Wiki](https://github.com/Alexays/Waybar/wiki).
- See the instructions in [battery-level.sh](/scripts/battery-level.sh) and [battery-state.sh](/scripts/battery-state.sh) to manually set up battery-related notifications.

## Roadmap

Here are some features and improvements planned for future versions:

- [ ] Theme switcher
- [ ] Style switcher

## Credits

- Font icons: [ryanoasis / nerd-fonts](https://github.com/ryanoasis/nerd-fonts)
- Color palette: [catppuccin / catppuccin](https://github.com/catppuccin/catppuccin) (Mocha)
- The original files in the [modules](/modules/) folder are from [prasanthrangan / hyprdots](https://github.com/prasanthrangan/hyprdots).
- The original versions of [battery-level.sh](/scripts/battery-level.sh) and [battery-state.sh](/scripts/battery-state.sh) are from [ericmurphyxyz / dotfiles](https://github.com/ericmurphyxyz/dotfiles)
- Special thanks to [JustLap](https://github.com/JustLap) for helping me organize font sizes into a dedicated section.
