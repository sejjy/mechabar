# mecha-bar
![Mecha Bar](/preview/mecha-bar.png)

## System Information
This configuration is tested and optimized for the following system setup:

- **Operating System**: Arch Linux
- **Display Server**: Wayland
- **Window Manager**: Hyprland
- **Audio**: PipeWire with WirePlumber
- **Monitor Resolution**: 1920x1080

> **Note:** This configuration is initially designed for laptops.

## Installation
1. **Clone the repository:**

   ```bash
   git clone https://github.com/Sejjy/mecha-bar.git
   cd mecha-bar
   ```
2. **Copy the configuration files:**

    Copy the `config.jsonc`, `style.css`, and `theme.css` files to your Waybar configuration directory:
    ```bash
    cp config.jsonc ~/.config/waybar/
    cp style.css ~/.config/waybar/
    cp theme.css ~/.config/waybar/
   ```
3. **Setup scripts:**

    Copy the scripts from the `scripts` directory to `~/.local/share/bin`:
    ```bash
    mkdir -p ~/.local/share/bin
    cp scripts/* ~/.local/share/bin/
    ```

    > **Note:** The `mediaplayer.py` script requires Python 3 to function. Make sure Python 3 is installed on your system:
    - **Arch Linux**

        ```bash
        sudo pacman -S python
        ```
4. **Restart Waybar**

    After copying the files, restart Waybar to apply the changes:
    ```bash
    killall waybar
    waybar &
    ```

## Customization
Feel free to modify the configuration files to fit your preferences.

## Credits
This configuration uses base modules and scripts from prasanthrangan's [hyprdots](https://github.com/prasanthrangan/hyprdots) which served as the foundation for this setup.


