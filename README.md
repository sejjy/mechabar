# 🤖 MechaBar

![MechaBar](/assets/v1.2.0.png)

#

<a id="wifi-menu"></a>

<details>
    <summary><strong>&nbsp;🛜 Wi-Fi Menu</strong></summary>
    <br>
    <img src="assets/wifimenu.png" alt="Wi-Fi Menu" />
</details>

<a id="logout-menu"></a>

<details>
    <summary><strong>&nbsp;⏸️ Logout Menu</strong></summary>
    <br>
    <table>
        <tr>
            <td><img src="assets/logout1.0.png" alt="Logout Menu 1.0" /></td>
            <td><img src="assets/logout1.1.png" alt="Logout Menu 1.1" /></td>
        </tr>
        <tr>
            <td><img src="assets/logout2.0.png" alt="Logout Menu 2.0" /></td>
            <td><img src="assets/logout2.1.png" alt="Logout Menu 2.1" /></td>
        </tr>
    </table>
</details>

## System Information

This configuration is initially tested and optimized for a **laptop** with the following system setup:

- Arch Linux
- Wayland
- Hyprland
- 1920x1080

## Dependencies

To ensure _MechaBar_ works properly after [installation](#installation), install the following dependencies:

|                           |                                                                                   |
| ------------------------- | --------------------------------------------------------------------------------- |
| `pipewire`                | Low-latency audio/video router and processor                                      |
| `wireplumber`             | Session/policy manager implementation for PipeWire                                |
| `playerctl`               | MPRIS media player controller for Spotify, VLC, Audacious, BMP, XMMS2, and others |
| `brightnessctl`           | Lightweight brightness control tool                                               |
| `python`                  | The Python programming language                                                   |
| `rofi`                    | A window switcher, application launcher, and dmenu replacement                    |
| `wlogout`                 | A Wayland-based logout menu                                                       |
| `ttf-jetbrains-mono-nerd` | Patched font JetBrains Mono from the nerd fonts library                           |
| `networkmanager`          | Network connection manager and user applications                                  |

> [!NOTE]
> If you wish to stick with your own alternatives, please refer to the [Customization](#customization) section.

## Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/sejjy/mechabar.git
   cd mechabar
   ```

2. **Copy the configuration files:**

   Copy the `config.jsonc`, `style.css`, and `theme.css` files to `~/.config/waybar`:

   ```bash
   mkdir -p ~/.config/waybar/
   cp config.jsonc ~/.config/waybar/
   cp style.css ~/.config/waybar/
   cp theme.css ~/.config/waybar/
   ```

3. **Setup scripts:**

   Copy the [scripts](/scripts/) folder to `~/.config/waybar`:

   ```bash
   cp -r scripts ~/.config/waybar/
   ```

   Copy the scripts to `~/.local/share/bin`:

   ```bash
   mkdir -p ~/.local/share/bin
   cp scripts/* ~/.local/share/bin/
   ```

4. **Additional configuration files:**

   **[Wi-Fi Menu](#wifi-menu)**: Copy the files to `~/.config/rofi`:

   ```bash
   mkdir -p ~/.config/rofi
   cp -r rofi/* ~/.config/rofi/
   ```

   **[Logout Menu](#logout-menu)**: Copy the files to `~/.config/wlogout`:

   ```bash
   mkdir -p ~/.config/wlogout
   cp -r wlogout/* ~/.config/wlogout/
   ```

5. **Restart Waybar to apply the changes:**

   ```bash
   killall waybar
   waybar &
   ```

## Customization

> [!IMPORTANT]
> You can modify the files to match your setup. However, if you use alternative [dependencies](#dependencies), you'll need to adjust the [scripts](/scripts/) and configurations accordingly.

## Credits

This setup uses base modules and scripts from **[prasanthrangan](https://github.com/prasanthrangan)'s [hyprdots](https://github.com/prasanthrangan/hyprdots)**.

The color scheme is based on the **[catppuccin](https://github.com/catppuccin/catppuccin) mocha [palette](https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md)**.
