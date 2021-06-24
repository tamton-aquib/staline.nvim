# staline.nvim
TLDR;<br/> staline(**sta**tus**line**): A simple statusline for neovim in pure lua.<br/>
stabline(s-**tabline**): A simple bufferline for neovim pure in lua. (sry didnt get a better name.)

### Requirements
* Requires neovim version 0.5.0+
* `vim.opt.laststatus=2` in your init.lua for statusline.
* `vim.opt.showtabline=2` in your init.lua for tabline.

### Installation
* Vim-plug:
    ```vim
    Plug 'tamton-aquib/staline.nvim'
    ```
* Packer
    ```lua
    use { 'tamton-aquib/staline.nvim' }
    ```
**PS**: Doing this will install both staline and stabline.

# Statusline

### Screenshots
![normal mode](https://i.imgur.com/1gXX22o.png)
![insert mode](https://i.imgur.com/0bP6y0S.png)
![visual mode](https://i.imgur.com/v1sejC8.png)
![command mode](https://i.imgur.com/TD9CGJ6.png)


* Configuration
	```lua
	require('staline').setup{}
	```
* The Default configuration looks something like:
    ```lua
    require('staline').setup {
		defaults = {
			left_separator   = "",
			right_separator  = "",
			line_column      = "[%l/%L] :%c 並%p%% ", -- `:h stl` to see all flags.
			fg               = "#000000",  -- Foreground text color.
			bg               = "none",     -- Default background is transparent.
			cool_symbol      = " ",       -- Change this to override defult OS icon.
			filename_section = "center",   -- others: right, left, none or custom string.
			full_path        = false
		},
		mode_colors = {
			n = "#2bbb4f",
			i = "#986fec",
			c = "#e27d60",
			v = "#4799eb",
		},
		mode_icons = {
			n = " ",
			i = " ",
			c = " ",
			v = " ",
		}
    }
    ```
<details>

<summary> Some useful config Ideas: </summary>

> Create color value tables to match your current colorscheme.
```lua
local gruvbox = {
	n = "#a89985",
	i = "#84a598",
	c = "#8fbf7f",
	v = "#fc802d",    -- etc...
}

-- Assign this table as mode_colors
require('staline').setup{
	mode_colors = gruvbox
}
```
> Use non-unicode characters for showing modes.
```lua
local no_unicode_modes = {
	n = "N ",
	i = "I ",
	c = "C ",
	v = "V ",    -- etc...
}

-- Assign this table as mode_icons.
require('staline').setup{
	mode_icons = no_unicode_modes
}

-- You could change the seperators too if you want.
```
> My personal config as of editing this file:

![staline.nvim](https://i.imgur.com/TCWcnP9.png)
```lua
require('staline').setup {
	defaults = {
		cool_symbol = " ",
		left_separator = "",
		right_separator = "",
	},
	mode_colors = {
		n = "#e27d60"
	}
}
```

</details>

# Bufferline

### Screenshots
![bar mode](https://i.imgur.com/stkcUAu.png)
![slant mode](https://i.imgur.com/UVS9ii5.png)
![arrow mode](https://i.imgur.com/ERDzicw.png)
![bubble mode](https://i.imgur.com/UjbeyjR.png)


* Configuration
	```lua
	require('stabline').setup{}
	```
* The Default configuration looks something like:
    ```lua
    require('stabline').setup {
		defaults = {
			style       = "bar", -- others: 'arrow', 'slant', 'bubble'
			stab_left   = "┃",   -- 😬
			stab_right  = " ",
			fg          = Default is fg of "Normal".
			bg          = Default is bg of "Normal".
			stab_bg     = Default is darker version of bg.
		},
    }
    ```
<details>

<summary>My personal config as of editing this file:</summary>

<!-- ![my stabline config](https://i.imgur.com/7PsnDGa.png) -->
![my stabline config](https://i.imgur.com/cmBdfzx.png)

```lua
require('stabline').setup {
	style = 'slant'
}
```

</details>

### Features
* Lightweight ( ~ 100 LOC each) and Fast (doesn't show up in `nvim --startuptime` logs.)
* Unicode current mode info. Needs a Nerd Font to be installed.
* Shows current git branch if [plenary](https://github.com/nvim-lua/plenary.nvim) is installed. (Used by Telescope)
* Uses [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons) if installed, else uses a default table.

#### Cons
* No lsp info. *(in both staline and stabline)*
* No mouse functions for stabline.
* No ordering or sorting functions for stabline.
* No git related info on staline except branch name.

---

#### Inspirations:
* [This](https://www.reddit.com/r/vim/comments/ld8h2j/i_made_a_status_line_from_scratch_no_plugins_used/) reddit post for staline.
* [akinsho/nvim-bufferline](https://github.com/akinsho/nvim-bufferline.lua) for stabline.

### TODO

- [x] Include more filetype support.
- [x] User configuration options. Needs more work.
- [x] Git info. Only branch info for now, *(or ever)*
- [x] Adding "opt-in" bufferline function.
- [x] Add config options for tabline.
- [ ] icon highlight issue if user sets fg for stabline.
