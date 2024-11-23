<div align="center">
  <h1>🤖 Mechabar</h1>

  <table>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/db1b6e0c-adb0-4340-a809-9b3f72494a38" alt="Preview 1" /></td>
    </tr>
  </table>

  <details>
    <summary><strong>&nbsp;🛜 Wi-Fi</strong> &amp; <strong>Bluetooth Menu</strong></summary>
    <br />
    <table>
      <tr>
        <td><img src="https://github.com/user-attachments/assets/0a93980d-9978-4f11-bad2-aca71eadce46" alt="Wi-Fi Menu" /></td>
      </tr>
      <tr>
        <td><img src="https://github.com/user-attachments/assets/59532fc9-2c99-495f-8379-23a3a7c73712" alt="Bluetooth Menu" /></td>
      </tr>
      <tr>
        <td><img src="https://github.com/user-attachments/assets/7be2fb45-7437-4155-9c62-770592eeeb9c" alt="NMTUI and BlueTUI" /></td>
      </tr>
    </table>
  </details>

  <details>
    <summary><strong>&nbsp;⏸️ Logout Menu</strong></summary>
    <br />
    <table>
      <tr>
        <td><img src="https://github.com/user-attachments/assets/9095ebeb-e1ac-4fd5-a233-1fd25f41ae30" alt="Logout Menu 1" /></td>
      </tr>
      <tr>
        <td><img src="https://github.com/user-attachments/assets/d702d59e-1110-4b12-b42f-326193776c26" alt="Logout Menu 2" /></td>
      </tr>
    </table>
  </details>

<a href="https://github.com/sejjy/mechabar/stargazers#gh-dark-mode-only"
    ><img
      src="https://img.shields.io/github/stars/sejjy/mechabar?colorA=1e1e2e&colorB=f9e2af&style=for-the-badge"
  /></a>
<a href="https://github.com/sejjy/mechabar/commits#gh-dark-mode-only"
    ><img
      src="https://img.shields.io/github/last-commit/sejjy/mechabar?colorA=1e1e2e&colorB=a6e3a1&style=for-the-badge"
  /></a>
<a href="https://github.com/sejjy/mechabar/contributors#gh-dark-mode-only"
    ><img
      src="https://img.shields.io/github/contributors/sejjy/mechabar?colorA=1e1e2e&colorB=b4befe&style=for-the-badge"
  /></a>

<a href="https://github.com/sejjy/mechabar/stargazers#gh-light-mode-only"
    ><img
      src="https://img.shields.io/github/stars/sejjy/mechabar?colorA=cdd6f4&colorB=f9e2af&style=for-the-badge"
  /></a>
<a href="https://github.com/sejjy/mechabar/commits#gh-light-mode-only"
    ><img
      src="https://img.shields.io/github/last-commit/sejjy/mechabar?colorA=cdd6f4&colorB=a6e3a1&style=for-the-badge"
  /></a>
<a href="https://github.com/sejjy/mechabar/contributors#gh-light-mode-only"
    ><img
      src="https://img.shields.io/github/contributors/sejjy/mechabar?colorA=cdd6f4&colorB=b4befe&style=for-the-badge"
  /></a>

</div>

A mecha-themed **[Waybar](https://github.com/Alexays/Waybar)** configuration initially designed for **[Hyprland](https://github.com/hyprwm/Hyprland)**, but also compatible with **Sway** and other **Wlroots-based compositors** with minimal adjustments. Contributions are welcome, including opening **[issues](https://github.com/sejjy/mechabar/issues)**, submitting **[pull requests](https://github.com/sejjy/mechabar/pulls)** for bug fixes or enhancements, and adding support for other distributions and compositors through new branches.

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

   This backs up existing files, installs all necessary dependencies, configurations, and scripts.

#

### Manual

#### Dependencies

- Required:

  ```bash
  sudo pacman -S bluez-utils brightnessctl jq python
  ```

  With alternatives:

  ```bash
  sudo pacman -S pipewire ttf-jetbrains-mono-nerd wireplumber
  ```

- Optional (but recommended):

  ```bash
  yay -S bluetui rofi-lbonn-wayland-git wlogout
  ```

| Package                   | Description                                                                               |
| ------------------------- | ----------------------------------------------------------------------------------------- |
| `bluetui`                 | TUI for managing bluetooth devices                                                        |
| `bluez-utils`             | Development and debugging utilities for the bluetooth protocol stack                      |
| `brightnessctl`           | Lightweight brightness control tool                                                       |
| `jq`                      | Command-line JSON processor                                                               |
| `pipewire`                | Low-latency audio/video router and processor                                              |
| `python`                  | The Python programming language                                                           |
| `rofi-lbonn-wayland-git`  | A window switcher, application launcher and dmenu replacement (fork with Wayland support) |
| `ttf-jetbrains-mono-nerd` | Patched font JetBrains Mono from the nerd fonts library                                   |
| `wireplumber`             | Session/policy manager implementation for PipeWire                                        |
| `wlogout`                 | Logout menu for Wayland                                                                   |

> [!IMPORTANT]
> If you use alternatives, you may need to modify the [scripts](/scripts/) and configuration files accordingly.

#

#### Installation

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

   Rofi:

   ```bash
   mkdir -p ~/.config/rofi
   cp rofi/* ~/.config/rofi/
   ```

   Wlogout:

   ```bash
   mkdir -p ~/.config/wlogout
   cp -r wlogout/* ~/.config/wlogout/
   ```

3. **Setup scripts:**

   Waybar-exclusive:

   ```bash
   cd scripts
   mkdir -p ~/.config/waybar/scripts/
   cp bluetooth-menu.sh cpu-temp.sh cpu-usage.sh media-player.py system-update.sh wifi-menu.sh wifi-status.sh ~/.config/waybar/scripts/
   ```

   System-wide:

   ```bash
   mkdir -p ~/.local/share/bin/
   cp brightness-control.sh logout-menu.sh volume-control.sh ~/.local/share/bin/
   ```

   Make scripts executable:

   ```bash
   chmod +x ~/.config/waybar/scripts/*
   chmod +x ~/.local/share/bin/*
   ```

4. **Restart Waybar to apply the changes:**

   ```bash
   killall waybar
   nohup waybar >/dev/null 2>&1 &
   ```

## Customization

- You can change the colors in [theme.css](/theme.css) (for Waybar and Wlogout) and [theme.rasi](/rofi/theme.rasi) (for Rofi) to match your system theme.
- You can remove existing modules or add new ones from the [modules](/modules/) folder. For a complete list of available modules, visit the [Waybar Wiki](https://github.com/Alexays/Waybar/wiki).

## Roadmap

Here are some features and improvements planned for future versions:

- [ ] Theme switcher
- [x] Install script
- [x] Rofi Bluetooth menu
- [x] Improved logout menu

## Credits

- The original files in the [modules](/modules/) folder are from [prasanthrangan / hyprdots](https://github.com/prasanthrangan/hyprdots).
- Icons: [ryanoasis / nerd-fonts](https://github.com/ryanoasis/nerd-fonts)
- Color palette: [catppuccin / catppuccin](https://github.com/catppuccin/catppuccin) (Mocha)
