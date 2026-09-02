<div align="center">

## 🤖 mechabar

A modular Waybar configuration

| ![Preview](./assets/catppuccin-mocha.png) |
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

### Requirements

- [waybar](https://github.com/Alexays/Waybar)

#

### Installation

1. Back up your current Waybar configuration:

	```bash
	mv ~/.config/waybar{,.bak}
	```

2. Clone the repository:

	```bash
	git clone https://github.com/sejjy/mechabar.git ~/.config/waybar
	```

3. Install the dependencies and restart Waybar:

	```bash
	~/.config/waybar/install
	```

	> See [install](./install) for the list of dependencies.
#

### Configuration

<details>
<summary>Fonts/Icons</summary>

Different fonts render characters at different sizes, which can affect the
layout. If you prefer to use a different font, you may need to adjust the font
sizes in [style.css](./style.css).

You can search for icons on
[nerdfonts.com/cheat-sheet](https://www.nerdfonts.com/cheat-sheet). Most modules
use [nf-md-](https://www.nerdfonts.com/cheat-sheet?q=nf-md-) icons for
consistency.

#

</details>

<details>
<summary>Themes</summary>

To change the theme, import your preferred theme file from the
[themes](./themes/) directory to [style.css](./style.css). For example:

```css
/* @import "themes/catppuccin-mocha.css"; */
@import "themes/catppuccin-latte.css";
```

#

</details>

<details>
<summary>Custom</summary>

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

- [Waybar wiki](https://github.com/Alexays/Waybar/wiki)
- [Nerd Fonts wiki](https://github.com/ryanoasis/nerd-fonts/wiki)
