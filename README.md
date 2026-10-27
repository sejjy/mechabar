<div align="center">

## 🤖 mechabar

A <ins>mecha</ins>-themed Way<ins>bar</ins> configuration

| ![Default](./assets/catppuccin-mocha.png) |
| :---------------------------------------: |

<details>
<summary>Themes</summary>

| Catppuccin Mocha (default)                         |
| :------------------------------------------------: |
| ![Catppuccin Mocha](./assets/catppuccin-mocha.png) |

| Catppuccin Macchiato                                       |
| :--------------------------------------------------------: |
| ![Catppuccin Macchiato](./assets/catppuccin-macchiato.png) |

| Catppuccin Frappe                                    |
| :--------------------------------------------------: |
| ![Catppuccin Frappe](./assets/catppuccin-frappe.png) |

| Catppuccin Latte                                   |
| :------------------------------------------------: |
| ![Catppuccin Latte](./assets/catppuccin-latte.png) |

</details>
</div>

#

### Installation

1. Back up your existing Waybar configuration:

	```sh
	mv ~/.config/waybar ~/.config/waybar.bak
	```

2. Clone the repository into <ins>~/.config/waybar</ins>:

	```sh
	git clone https://github.com/sejjy/mechabar.git ~/.config/waybar
	```

3. Install the dependencies and restart Waybar:

	```sh
	~/.config/waybar/install
	```

	> See [install](./install) for the list of dependencies.
#

### Configuration

<details open>
<summary>Terminal</summary>

By default, modules use [kitty](https://github.com/kovidgoyal/kitty) to launch
command-line interfaces. If you use a different terminal, replace all instances
of "kitty" with your terminal command. For example:

```jsonc
// ~/.config/waybar/modules/custom/power.jsonc

"custom/power": {
	// "on-click": "kitty -e ~/.config/waybar/scripts/power",
	"on-click": "ghostty -e ~/.config/waybar/scripts/power",
}
```

#

</details>

<details>
<summary>Fonts & Icons</summary>

You can find patched fonts on
[nerdfonts.com](https://www.nerdfonts.com/font-downloads) and icons via their
[cheat sheet](https://www.nerdfonts.com/cheat-sheet). For consistency, most
modules use [Material Design](https://github.com/Templarian/MaterialDesign)
icons, prefixed with "[nf-md-](https://www.nerdfonts.com/cheat-sheet?q=nf-md-)".

#

</details>

<details>
<summary>Themes</summary>

To change the theme, import your preferred theme from the [themes](./themes/)
directory into [style.css](./style.css). For example:

```css
/* @import "themes/catppuccin-mocha.css"; */
@import "themes/catppuccin-latte.css";
```

#

</details>

<details>
<summary>Custom user module</summary>

The leftmost module is left for you to configure. For example:

```jsonc
// ~/.config/waybar/modules/custom/user.jsonc

"custom/user": {
	"on-click": "/path/to/your/script", // Run your own script
	"on-click-right": "pkill -SIGUSR2 waybar", // Restart Waybar
}
```

</details>

#

### References

- [Mecha](https://en.wikipedia.org/wiki/Mecha)
- [Waybar wiki](https://github.com/Alexays/Waybar/wiki)
- [Nerd Fonts wiki](https://github.com/ryanoasis/nerd-fonts/wiki)
